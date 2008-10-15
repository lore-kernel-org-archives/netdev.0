From: "Manish Katiyar" <mkatiyar@gmail.com>
Subject: Re: [PATCH] : Fix compilation warnings in net/802/fc.c
Date: Wed, 15 Oct 2008 09:06:12 +0530
Message-ID: <ea11fea30810142036i22d02a32i571fc0ea7c0e2dff@mail.gmail.com>
References: <ea11fea30810141121w58e25b43x92d71ca800c5c96@mail.gmail.com>
	 <20081014193500.GA6502@joi>
	 <20081014.163620.23535849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: marcin.slusarz@gmail.com, kernel-janitors@vger.kernel.org,
	netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.189]:23557 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751486AbYJODgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 23:36:14 -0400
Received: by ti-out-0910.google.com with SMTP id b6so1363424tic.23
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 20:36:12 -0700 (PDT)
In-Reply-To: <20081014.163620.23535849.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 15, 2008 at 5:06 AM, David Miller <davem@davemloft.net> wrote:
> From: Marcin Slusarz <marcin.slusarz@gmail.com>
> Date: Tue, 14 Oct 2008 21:35:04 +0200
>
>> On Tue, Oct 14, 2008 at 11:51:24PM +0530, Manish Katiyar wrote:
>> > diff --git a/net/802/fc.c b/net/802/fc.c
>> > index cb3475e..7463109 100644
>> > --- a/net/802/fc.c
>> > +++ b/net/802/fc.c
>> > @@ -82,7 +82,9 @@ static int fc_header(struct sk_buff *skb, struct
>> > net_device *dev,
>> >
>> >  static int fc_rebuild_header(struct sk_buff *skb)
>> >  {
>> > +#ifdef CONFIG_INET
>> >     struct fch_hdr *fch=(struct fch_hdr *)skb->data;
>> > +#endif
>> >     struct fcllc *fcllc=(struct fcllc *)(skb->data+sizeof(struct fch_hdr));
>> >     if(fcllc->ethertype != htons(ETH_P_IP)) {
>> >             printk("fc_rebuild_header: Don't know how to resolve type %04X
>> > addresses ?\n", ntohs(fcllc->ethertype));
>> > --
>>
>> When !CONFIG_INET this function always returns 0 (and does not anything useful)
>> so it probably can be written as:
>>
>> #ifdef CONFIG_INET
>> static int fc_rebuild_header(struct sk_buff *skb)
>> {
>> ...
>> }
>> #else
>> static int fc_rebuild_header(struct sk_buff *skb)
>> {
>>       return 0;
>> }
>> #endif
>
> Yep, agreed.  Could someone respin the patch like this?

Updated the below patch as per suggestions.

Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>

---
 net/802/fc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/802/fc.c b/net/802/fc.c
index cb3475e..34cf1ee 100644
--- a/net/802/fc.c
+++ b/net/802/fc.c
@@ -82,13 +82,13 @@ static int fc_header(struct sk_buff *skb, struct
net_device *dev,

 static int fc_rebuild_header(struct sk_buff *skb)
 {
+#ifdef CONFIG_INET
 	struct fch_hdr *fch=(struct fch_hdr *)skb->data;
 	struct fcllc *fcllc=(struct fcllc *)(skb->data+sizeof(struct fch_hdr));
 	if(fcllc->ethertype != htons(ETH_P_IP)) {
 		printk("fc_rebuild_header: Don't know how to resolve type %04X
addresses ?\n", ntohs(fcllc->ethertype));
 		return 0;
 	}
-#ifdef CONFIG_INET
 	return arp_find(fch->daddr, skb);
 #else
 	return 0;
-- 
1.5.4.3

Thanks -
Manish

>
> Thanks.
>
