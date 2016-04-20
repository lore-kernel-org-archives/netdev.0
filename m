From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 1/4] netlink: fix test alignment in
 nla_align_64bit()
Date: Wed, 20 Apr 2016 02:33:22 -0700
Message-ID: <1461144802.10638.249.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160419.195009.1052027353987244150.davem@davemloft.net>
	 <1461142655-5067-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1461142655-5067-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	roopa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35011 "EHLO
	mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932994AbcDTJdU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2016 05:33:20 -0400
Received: by mail-pf0-f169.google.com with SMTP id n1so16644075pfn.2
        for <netdev@vger.kernel.org>; Wed, 20 Apr 2016 02:33:19 -0700 (PDT)
In-Reply-To: <1461142655-5067-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-04-20 at 10:57 +0200, Nicolas Dichtel wrote:
> IS_ALIGN() returns true when the alignment is as expected. The pad
> attribute should be added only when the alignment is not 8.
> 
> Fixes: 35c5845957c7 ("net: Add helpers for 64-bit aligning netlink attributes.")
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
> ---
>  include/net/netlink.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/include/net/netlink.h b/include/net/netlink.h
> index e644b3489acf..694caac31d2c 100644
> --- a/include/net/netlink.h
> +++ b/include/net/netlink.h
> @@ -1245,7 +1245,7 @@ static inline int nla_validate_nested(const struct nlattr *start, int maxtype,
>  static inline int nla_align_64bit(struct sk_buff *skb, int padattr)
>  {
>  #ifndef HAVE_EFFICIENT_UNALIGNED_ACCESS
> -	if (IS_ALIGNED((unsigned long)skb->data, 8)) {
> +	if (!IS_ALIGNED((unsigned long)skb->data, 8)) {
>  		struct nlattr *attr = nla_reserve(skb, padattr, 0);
>  		if (!attr)
>  			return -EMSGSIZE;

This is silly.

How have you tested your patch exactly ?

I guess David should have copied his original comment here.

-        * The nlattr header is 4 bytes in size, that's why we test
-        * if the skb->data _is_ aligned.  This NOP attribute, plus
-        * nlattr header for IFLA_STATS64, will make nla_data() 8-byte
-        * aligned.
