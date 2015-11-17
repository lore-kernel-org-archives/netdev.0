From: Ben Greear <greearb@candelatech.com>
Subject: How to do TCP tx checksums
Date: Mon, 16 Nov 2015 16:20:35 -0800
Message-ID: <564A72D3.1050407@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:54564 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751236AbbKQAUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2015 19:20:36 -0500
Received: from [192.168.100.149] (firewall.candelatech.com [50.251.239.81])
	(using TLSv1.2 with cipher DHE-RSA-AES128-SHA (128/128 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id 35C8540B24A
	for <netdev@vger.kernel.org>; Mon, 16 Nov 2015 16:20:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

I'm hacking on (my already hacked) pktgen, trying to get it to send TCP frames.

And, having issues getting checksums to work properly.

I'm trying this:
	struct iphdr *iph = ip_hdr(skb);
	struct net_device *odev = pkt_dev->odev;

	if (pkt_dev->flags & F_TCP) {
		if (odev->features & NETIF_F_V4_CSUM) {
			skb->ip_summed = CHECKSUM_PARTIAL;
		} else {
			skb->ip_summed = CHECKSUM_NONE;
		}
		skb->csum = 0;
		__tcp_v4_send_check(skb, iph->saddr, iph->daddr);

I added an export so I could call that __tcp_v4_send_check method
w/out having to put a fake socket struct on the stack.

But, the receiving NIC reports 100% checksum failure, so obviously
I'm not doing it correct.

Any suggestions on what I might be doing wrong or the proper method(s)
to call?

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
