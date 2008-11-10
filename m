From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Mon, 10 Nov 2008 12:29:29 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61126@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
	 <1225838743.6116.20.camel@fry>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
	 <20081106080316.GA32337@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FA8@NASANEXMB10.na.qualcomm.com>
	 <20081106194032.GB31673@ioremap.net>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60FBE@NASANEXMB10.na.qualcomm.com>
 <7e0dd21a0811070836q8deb631qe8093282229b403e@mail.gmail.com>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Lovich, Vitali" <vlovich@qualcomm.com>,
	Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine01.qualcomm.com ([199.106.114.254]:18703 "EHLO
	wolverine01.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752034AbYKJU3b convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2008 15:29:31 -0500
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA61024@NASANEXMB10.na.qualcomm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Johann,

Found another issue.  I'm not sure how your code managed to work, but in my patch I had to have skb_reset_network_header(skb) after a skb_reserve - otherwise, it would be rejected when I passed it on to the device.

Also, there's no need to support both header versions in the tx path - since v2 should be used anyways and there's no legacy (v1 headers are deprecated no?), we can use v2 only in the tx path.

Additionally, if the packet size is too long, the kernel has a responsibility to clear that flag (otherwise that slot will never free up).

I'm going to review the code a little bit more later on today as I try to integrate our versions.
