From: Wei Yongjun <weiyj@soft.fujitsu.com>
Subject: Re: [PATCH]ip_options_fragment() has no effect on fragmentation
Date: Fri, 05 May 2006 20:36:14 -0400
Message-ID: <1146875774.3659.22.camel@LINE>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: weiyj@soft.fujitsu.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:49091 "EHLO
	fgwmail6.fujitsu.co.jp") by vger.kernel.org with ESMTP
	id S932350AbWEHHLB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 May 2006 03:11:01 -0400
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
        by fgwmail6.fujitsu.co.jp (Fujitsu Gateway)
        with ESMTP id k487B0ur024634 for <netdev@vger.kernel.org>; Mon, 8 May 2006 16:11:00 +0900
        (envelope-from weiyj@soft.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp by m4.gw.fujitsu.co.jp (8.12.10/Fujitsu Domain Master)
	id k487Aw6U017442 for <netdev@vger.kernel.org>; Mon, 8 May 2006 16:10:58 +0900
	(envelope-from weiyj@soft.fujitsu.com)
Received: from s6.gw.fujitsu.co.jp (s6 [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id B730D2AB09E
	for <netdev@vger.kernel.org>; Mon,  8 May 2006 16:10:58 +0900 (JST)
Received: from mail1-sv.soft.fujitsu.com (smtp.soft.fujitsu.com [10.124.20.52])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 470D62AB1B3
	for <netdev@vger.kernel.org>; Mon,  8 May 2006 16:10:58 +0900 (JST)
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I had tested the patch under linux system, maybe this mail is correct.

Fix error point to options in ip_options_fragment(). optptr get a error
pointer to the ipv4 header, correct is pointer to ipv4 options.

Signed-off-by: Wei Yongjun <weiyj@soft.fujitsu.com>

--- a/net/ipv4/ip_options.c	2006-01-27 09:14:33.463612696 +0900
+++ b/net/ipv4/ip_options.c	2006-01-27 09:12:21.857619848 +0900
@@ -207,7 +207,7 @@
 
 void ip_options_fragment(struct sk_buff * skb) 
 {
-	unsigned char * optptr = skb->nh.raw;
+	unsigned char * optptr = skb->nh.raw + sizeof(struct iphdr);
 	struct ip_options * opt = &(IPCB(skb)->opt);
 	int  l = opt->optlen;
 	int  optlen;


On Monday 08 May 2006 01:41, David S. Miller wrote:
> Actually it didn't get applied for some reason.
>
> Please resubmit it properly with a full changelog and
> "Signed-off-by: " lines, and make double sure that your
> email client does not corrupt the patch so that I may
> apply it cleanly.  Test this by sending it to yourself
> and trying to apply the patch.

