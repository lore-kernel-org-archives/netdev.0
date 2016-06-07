From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: GSO packets on lower MTU retaining gso_size?
Date: Tue, 7 Jun 2016 06:05:26 +0000
Message-ID: <CO2PR11MB008861B24F9DA5CBA56F58C8975D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0104.outbound.protection.outlook.com ([65.55.169.104]:28224
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750792AbcFGGFb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2016 02:05:31 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While experimenting with Vxlan tunnels, I've reached a topology where the
Vxlan interface's MTU was 1500 while base-interface was smaller [600].

While 'regular' packets broke via ip-fragmentation, GSO SKBs passing from
the vxlan interface to the base interface remained whole, and their 
`gso_size' remained matching to that of the vxlan-interface's MTU;
This caused the HW to drop said packets, as it would have resulted with
the device sending to the line packets with length larger than the mtu.

Is this broken on the udp-tunnel transmit path, the setup or the driver [qede]?
