From: hayeswang <hayeswang@realtek.com>
Subject: RE: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Wed, 18 Jul 2012 14:45:55 +0800
Message-ID: <AC35CD5731C3479B9BF5E53BF541A81F@realtek.com.tw>
References: <1342564781.2626.1264.camel@edumazet-glaptop> <20120717234037.GA26972@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: 'Francois Romieu' <romieu@fr.zoreil.com>,
	'Eric Dumazet' <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtits2.realtek.com ([60.250.210.242]:46969 "EHLO
	rtits2.realtek.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751080Ab2GRGqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 02:46:06 -0400
In-Reply-To: <20120717234037.GA26972@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francois Romieu [mailto:romieu@fr.zoreil.com] 
[...]

> Hayes, should we not add into the kernel driver something similar to
> the rtl8168_start_xmit::skb_checksum_help stuff in Realtek's 
> 8168 driver ?
> There seems to be a bug for (skb->len < 60 && RTL_GIGA_MAC_VER_34.

For RTL8168E-VL (RTL_GIGA_MAC_VER_34), the hardware wouldn't send the packet
with the length less than 60 bytes. The hardware should pad this kind of packet
to 60 bytes, but it wouldn't. Therefore, the software has to pad the packet to
60 bytes. However, the hw checksum would be incorrect for the modified packet,
so the software checksum is necessary. That is, for the packet less than 60
bytes, the software has to pad the packet and calculate the checksum, and the hw
checksum has to be disabled.
 
Best Regards,
Hayes
