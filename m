From: Peter Kosyh <p.kosyh@gmail.com>
Subject: Re: [PATCH] xfrm bugs with mark logic
Date: Fri, 2 Jul 2010 20:24:03 +0400
Message-ID: <20100702162403.GA10809@myhost>
References: <AANLkTimsVHoNk3B1oTI6awlNtrmNED7vwe2flzTap9aP@mail.gmail.com> <1278082898.2530.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="liOOAslEiF7prFVr"
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:49031 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759079Ab0GBQYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Jul 2010 12:24:12 -0400
Received: by bwz1 with SMTP id 1so1684212bwz.19
        for <netdev@vger.kernel.org>; Fri, 02 Jul 2010 09:24:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1278082898.2530.37.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--liOOAslEiF7prFVr
Content-Type: text/plain; charset=koi8-r
Content-Disposition: inline

> 
> Hi Peter
> 
> XFRMA_MARK part already in net-2.6 tree :
> 
> http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.git;a=commit;h=4efd7e833591721bec21cc4730a7f6261417840f
> 
> Please submit another patch the second problem you spotted ?
> 

Yes, i see. Here it is, but i am little unsure about ipv6 fix.

-- 
w.b.r. Peter Kosyh

--liOOAslEiF7prFVr
Content-Type: text/plain; charset=koi8-r
Content-Disposition: attachment; filename="linux-2.6.36-xfrm-mark.patch"

diff -Nur linux-2.6.35-rc3.orig/net/ipv4/xfrm4_policy.c linux-2.6.35-rc3/net/ipv4/xfrm4_policy.c
--- linux-2.6.35-rc3.orig/net/ipv4/xfrm4_policy.c	2010-06-12 06:14:04.000000000 +0400
+++ linux-2.6.35-rc3/net/ipv4/xfrm4_policy.c	2010-07-02 20:20:49.000000000 +0400
@@ -108,6 +108,8 @@
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
 
 	memset(fl, 0, sizeof(struct flowi));
+	fl->mark = skb->mark;
+
 	if (!(iph->frag_off & htons(IP_MF | IP_OFFSET))) {
 		switch (iph->protocol) {
 		case IPPROTO_UDP:
diff -Nur linux-2.6.35-rc3.orig/net/ipv6/xfrm6_policy.c linux-2.6.35-rc3/net/ipv6/xfrm6_policy.c
--- linux-2.6.35-rc3.orig/net/ipv6/xfrm6_policy.c	2010-06-12 06:14:04.000000000 +0400
+++ linux-2.6.35-rc3/net/ipv6/xfrm6_policy.c	2010-07-02 20:20:22.000000000 +0400
@@ -124,6 +124,8 @@
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
 
 	memset(fl, 0, sizeof(struct flowi));
+	fl->mark = skb->mark;
+
 	ipv6_addr_copy(&fl->fl6_dst, reverse ? &hdr->saddr : &hdr->daddr);
 	ipv6_addr_copy(&fl->fl6_src, reverse ? &hdr->daddr : &hdr->saddr);
 

--liOOAslEiF7prFVr--
