From: Yuri Chislov <YChislov@trustwave.com>
Subject: ip6_gre wccp header changed top ipv4, while should be changed to
 ipv6
Date: Thu, 13 Nov 2014 06:08:15 +0000
Message-ID: <A1EED8F96500564EA7E8F2BFA79D279E4A521941@SKYMB1.trustwave.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from seg-node-elk-02.trustwave.com ([204.13.202.189]:11375 "EHLO
	seg-node-elk-02.trustwave.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753626AbaKMGXV convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 13 Nov 2014 01:23:21 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

 wccp v 2.01 forward gre packet with protocol type WCCP (0x883e) in gre header,
that replaced with ETH_P_IP, while encapsulated ipv6 packet (ETH_P_IPV6).

 Tested on 3.14.23, the same code is in 3.17.2

======================================
--- a/ip6_gre.c 2014-11-11 11:33:30.820695876 +0000
+++ b/ip6_gre.c 2014-11-11 11:34:19.480694111 +0000
@@ -512,7 +512,7 @@
                 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
                 */
                if (flags == 0 && gre_proto == htons(ETH_P_WCCP)) {
-                       skb->protocol = htons(ETH_P_IP);
+                       skb->protocol = htons(ETH_P_IPV6);
                        if ((*(h + offset) & 0xF0) != 0x40)
                                offset += 4;
                }
======================================

 One more issue noted in ip6_gre.
ipv4 gre interface configured to local any remote any
receive(accept) all gre traffic.
ipv6 gre interface should be configured explicit to exact remote and
local addresses
to receive traffic in gre interface, that a bit problematic due to
multiply addresses
assigned to interface. I will try to understand this issue, but possible someone
have some ideas

Thanks.
Yuri.

________________________________

This transmission may contain information that is privileged, confidential, and/or exempt from disclosure under applicable law. If you are not the intended recipient, you are hereby notified that any disclosure, copying, distribution, or use of the information contained herein (including any reliance thereon) is strictly prohibited. If you received this transmission in error, please immediately contact the sender and destroy the material in its entirety, whether in electronic or hard copy format.
