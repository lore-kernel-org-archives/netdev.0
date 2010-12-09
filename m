From: "avagin@gmail.com" <avagin@gmail.com>
Subject: Re: [stable] [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot
 for GSO case too
Date: Thu, 09 Dec 2010 09:43:03 +0300
Message-ID: <4D007A77.8050102@gmail.com>
References: <20101011.085952.193718228.davem@davemloft.net> <4CB33907.5060803@gmail.com> <1286814652.2737.41.camel@edumazet-laptop> <20101026.115434.241921999.davem@davemloft.net> <4D000B0D.2060101@gmail.com> <20101208230536.GA8062@kroah.com>
Reply-To: avagin@gmail.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040107060307060301070902"
Cc: Greg Kroah-Hartman <gregkh@suse.de>, krkumar2@in.ibm.com,
	avagin@openvz.org, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mjt@tls.msk.ru, David Miller <davem@davemloft.net>,
	stable@kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f45.google.com ([209.85.215.45]:50830 "EHLO
	mail-ew0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426Ab0LIGnI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Dec 2010 01:43:08 -0500
Received: by ewy10 with SMTP id 10so1461104ewy.4
        for <netdev@vger.kernel.org>; Wed, 08 Dec 2010 22:43:07 -0800 (PST)
In-Reply-To: <20101208230536.GA8062@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040107060307060301070902
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

I add the patch in attachments

On 12/09/2010 02:05 AM, Greg KH wrote:
> On Thu, Dec 09, 2010 at 01:47:41AM +0300, avagin@gmail.com wrote:
>> Hi Greg,
>>
>> This patch is acked by David S. Miller. Greg, maybe you can commit it?
>
> What specific patch please?
>
> confused,
>
> greg k-h


--------------040107060307060301070902
Content-Type: message/rfc822;
 name="Attached Message"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="Attached Message"

Delivered-To: avagin@gmail.com
Received: by 10.229.236.21 with SMTP id ki21cs133042qcb;
        Mon, 11 Oct 2010 08:24:03 -0700 (PDT)
Received: by 10.224.96.200 with SMTP id i8mr4527147qan.152.1286810642441;
        Mon, 11 Oct 2010 08:24:02 -0700 (PDT)
Return-Path: <avagin@openvz.org>
Received: from vzorg.swsoft.net (openvz.org [64.131.90.7])
        by mx.google.com with ESMTP id u28si10063991qco.162.2010.10.11.08.24.01;
        Mon, 11 Oct 2010 08:24:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of avagin@openvz.org designates 64.131.90.7 as permitted sender) client-ip=64.131.90.7;
Authentication-Results: mx.google.com; spf=pass (google.com: domain of avagin@openvz.org designates 64.131.90.7 as permitted sender) smtp.mail=avagin@openvz.org
Received: from mx1.parallels.com (mx1.parallels.com [64.131.89.18])
	by vzorg.swsoft.net (8.13.1/8.13.1) with ESMTP id o9BFO1Jx029765
	for <avagin@openvz.org>; Mon, 11 Oct 2010 11:24:01 -0400
Received: from mailhub.sw.ru ([195.214.232.25] helo=relay.sw.ru)
	by mx1.parallels.com with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.71)
	(envelope-from <avagin@openvz.org>)
	id 1P5KEL-0006pD-1V
	for avagin@openvz.org; Mon, 11 Oct 2010 11:24:01 -0400
Received: from dhcp-10-30-18-117.sw.ru ([10.30.21.236])
	by relay.sw.ru (8.13.4/8.13.4) with ESMTP id o9BFKqSY004037;
	Mon, 11 Oct 2010 19:20:53 +0400 (MSD)
From: Andrey Vagin <avagin@openvz.org>
To: stable@kernel.org
Cc: netdev@vger.kernel.org, Krishna Kumar <krkumar2@in.ibm.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andrey Vagin <avagin@openvz.org>
Subject: [STABLE 2.6.32 PATCH] net: release dst entry while cache-hot for GSO case too
Date: Mon, 11 Oct 2010 19:20:13 +0400
Message-Id: <1286810413-30238-1-git-send-email-avagin@openvz.org>
X-Mailer: git-send-email 1.7.2.1
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-2.0.2 (vzorg.swsoft.net [64.131.90.7]); Mon, 11 Oct 2010 11:24:01 -0400 (EDT)

From: Krishna Kumar <krkumar2@in.ibm.com>

commit 068a2de57ddf4f472e32e7af868613c574ad1d88 upstream.

Non-GSO code drops dst entry for performance reasons, but
the same is missing for GSO code. Drop dst while cache-hot
for GSO case too.

Note: Without this patch the kernel may oops if used bridged veth
devices. A bridge set skb->dst = fake_dst_ops, veth transfers this skb
to netif_receive_skb...ip_rcv_finish and it calls dst_input(skb), but
fake_dst_ops->input = NULL -> Oops

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Andrey Vagin <avagin@openvz.org>
---
 net/core/dev.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 915d0ae..c325ab6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1747,6 +1747,14 @@ gso:
 
 		skb->next = nskb->next;
 		nskb->next = NULL;
+
+		/*
+		 * If device doesnt need nskb->dst, release it right now while
+		 * its hot in this cpu cache
+		 */
+		if (dev->priv_flags & IFF_XMIT_DST_RELEASE)
+			skb_dst_drop(nskb);
+
 		rc = ops->ndo_start_xmit(nskb, dev);
 		if (unlikely(rc != NETDEV_TX_OK)) {
 			nskb->next = skb->next;
-- 
1.7.2.1


--------------040107060307060301070902--
