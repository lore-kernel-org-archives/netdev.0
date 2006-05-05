From: weiyj@soft.fujitsu.com
Subject: Re: [PATCH]ip_options_fragment() has no effect on fragmentation
Date: Fri, 5 May 2006 13:50:02 -0400
Message-ID: <200605051350.03300.weiyj@soft.fujitsu.com>
References: <001701c6277a$eaa93950$cfa0220a@WeiYJ> <1138821701.3852.8.camel@L-tech1> <20060202.170840.114568749.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: weiyj@soft.fujitsu.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:56493 "EHLO
	fgwmail6.fujitsu.co.jp") by vger.kernel.org with ESMTP
	id S1750721AbWEHAat (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 May 2006 20:30:49 -0400
Received: from m7.gw.fujitsu.co.jp ([10.0.50.77])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k480UlQ5018746 for <netdev@vger.kernel.org>; Mon, 8 May 2006 09:30:47 +0900
        (envelope-from weiyj@soft.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp by m7.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k480UkoG008924 for <netdev@vger.kernel.org>; Mon, 8 May 2006 09:30:47 +0900
	(envelope-from weiyj@soft.fujitsu.com)
Received: from s1.gw.fujitsu.co.jp (s1 [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id A8F1C3B4170
	for <netdev@vger.kernel.org>; Mon,  8 May 2006 09:30:46 +0900 (JST)
Received: from localhost.localdomain (unknown [10.34.160.206])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46A663B416F
	for <netdev@vger.kernel.org>; Mon,  8 May 2006 09:30:46 +0900 (JST)
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060202.170840.114568749.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Mr. David:

Does this patch will be used? 

This patch resolved the following problem: When I send IPv4 packet(contain 
Record Route Option) which need to be fragmented to the router, the router 
can not fragment it correctly. After fragmented by router, the second 
fragmentation still contain Record Route Option. Refer to RFC791, Record 
Route Option must Not be copied on fragmentation, goes in first fragment 
only.

On Thursday 02 February 2006 20:08, David S. Miller wrote:
> From: Wei Yongjun <weiyj@soft.fujitsu.com>
> Date: Wed, 01 Feb 2006 14:21:41 -0500
>
> Your patch is still corrupt, new lines were added by your email client
> which splits up the patch headers.
>
> I applied the patch by hand, but next time I won't put so much effort
> into fixing up your work.  Please learn how to submit patches
> properly.
>
> Thank you.

--- a/net/ipv4/ip_options.c.orig 2006-01-27 09:14:33.463612696 +0900
+++ b/net/ipv4/ip_options.c 2006-01-27 09:12:21.857619848 +0900
@@ -207,7 +207,7 @@
 
 void ip_options_fragment(struct sk_buff * skb) 
 {
- unsigned char * optptr = skb->nh.raw;
+ unsigned char * optptr = skb->nh.raw + sizeof(struct iphdr);
  struct ip_options * opt = &(IPCB(skb)->opt);
  int  l = opt->optlen;
  int  optlen;
