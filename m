From: Yuri Chislov <yuri.chislov@gmail.com>
Subject: ip6_gre wccp header changed top ipv4, while should be changed to ipv6
Date: Thu, 13 Nov 2014 08:13:30 +0200
Message-ID: <CAAcAdL0vbwLfft5XT-DWvW_XB+XLgkko7V_sWm5D99F1KU-JSw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:34142 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbaKMGNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 01:13:31 -0500
Received: by mail-ig0-f170.google.com with SMTP id a13so631259igq.5
        for <netdev@vger.kernel.org>; Wed, 12 Nov 2014 22:13:30 -0800 (PST)
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
