From: "Denys Fedoryshchenko" <denys@visp.net.lb>
Subject: packet corruption or something else?
Date: Tue, 8 Jan 2008 14:49:18 +0200
Message-ID: <20080108123414.M75319@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:45295 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751097AbYAHMte (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 07:49:34 -0500
Received: from visp.net.lb (localhost [127.0.0.1])
	by usermail.globalproof.net (Postfix) with ESMTP id E9AAABCD53
	for <netdev@vger.kernel.org>; Tue,  8 Jan 2008 14:49:18 +0200 (EET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I notice a lot of messages like
[8447790.549705] UDP: short packet: From XXX.XXX.224.29:21005 60046/1480 to 
XXX.XXX.247.1:1024
[8448040.893317] UDP: short packet: From XXX.XXX.224.29:21218 17820/1480 to 
XXX.XXX.247.1:49974
[8448216.603759] UDP: short packet: From XXX.XXX.224.29:21004 56347/1480 to 
XXX.XXX.247.1:1024
[8448370.883610] UDP: short packet: From XXX.XXX.224.29:21005 5246/1480 to 
XXX.XXX.247.1:1251

I have similar messages on other hosts, and they looks very strange.

After looking to kernel sources i found
        ulen = ntohs(uh->len);
        if (ulen > skb->len)
                goto short_packet;

        if (proto == IPPROTO_UDP) {
                /* UDP validates ulen. */
                if (ulen < sizeof(*uh) || pskb_trim_rcsum(skb, ulen))
                        goto short_packet;
                uh = udp_hdr(skb);
        }

Means if specified length in packet header more large than len in skb, go to 
short_packet.

As i know for sure, i have running UDP application which sending packets not 
more than 1500 bytes (1480 actually without header), and it is running on 
ports 21005, 21004, 21006. There is for sure impossible it will send data 
from port 21218 and impossible it will send packet larger than 1480 bytes.

Receiving side is Intel card with hardware checksumming enabled. So in theory 
corrupted packets must not bypass hardware checksumming (but probably i am 
wrong). Is there anything suspicious and need additional attention?

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

