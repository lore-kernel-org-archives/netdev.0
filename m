From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ks8842: Support DMA when accessed via timberdale
Date: Tue, 27 Jul 2010 10:49:26 -0700 (PDT)
Message-ID: <20100727.104926.57485905.davem@davemloft.net>
References: <1280222297.13522.15.camel@debian>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: richard.rojfors@pelagicore.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59537
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752811Ab0G0RtJ convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jul 2010 13:49:09 -0400
In-Reply-To: <1280222297.13522.15.camel@debian>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Richard R=F6jfors <richard.rojfors@pelagicore.com>
Date: Tue, 27 Jul 2010 11:18:17 +0200

> This patch adds support for RX and TX DMA via the DMA API,
> this is only supported when the KS8842 is accessed via timberdale.
>=20
> There is no support for DMA on the generic bus interface it self,
> a state machine inside the FPGA is handling RX and TX transfers to/fr=
om
> buffers in the FPGA. The host CPU can do DMA to and from these buffer=
s.
>=20
> The FPGA has to handle the RX interrupts, so these must be enabled in
> the ks8842 but not in the FPGA. The driver must not disable the RX in=
terrupt
> that would mean that the data transfers into the FPGA buffers would s=
top.
>=20
> The host shall not enable TX interrupts since TX is handled by the FP=
GA,
> the host is notified by DMA callbacks when transfers are finished.
>=20
> Which DMA channels to use are added as parameters in the platform dat=
a struct.
>=20
> Signed-off-by: Richard R=F6jfors <richard.rojfors@pelagicore.com>

Please, no more crazy config options, make the code dynamically use
DMA or not based upon information passed in via the platform_device
object at probe time.
