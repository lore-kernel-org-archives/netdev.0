From: Pierre Ynard <linkfanel@yahoo.fr>
Subject: Rare NIC "crash" with 3c905B
Date: Fri, 9 Mar 2007 03:47:30 +0100
Message-ID: <20070309024730.GA26884@via.ecp.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from durga.via.ecp.fr ([138.195.130.75]:40620 "EHLO durga.via.ecp.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030860AbXCIDH7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Mar 2007 22:07:59 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I think that I found a problem with 3c905B Cyclone 100baseTx cards,
supported by the 3c59x driver. Please have a look at:

http://bugzilla.kernel.org/show_bug.cgi?id=3D7440

In short, the device stores received packets through DMA into buffers o=
n
a rx_ring, which has a default size of 32 packets. It happens on my
network that my card will receive 32 packets (and likely more than that=
)
before the interrupt handler is called to handle these packets. As a
result, 32 packets are successfully read and the interrupt handler
returns, but after that, no more interrupt is ever sent by the device
to signal the reception of new incoming packets. This results in an
almost total loss of connectivity for the host. Reloading the driver
module restores normal condition.

I can provide extensive logs of this. I tried changing the RX_RING_SIZE
constant from 32 to 256 packets, and it definitely solved the problem,
as my network is not weird enough to send me 256 packets at the same
time yet :) Please don't ask me to try with another card of the same
model, as I'm currently not on the same continent as this server
(though I'd be very happy to conclude that the problem can be solved by
simply swapping the card).

I have little experience with this kind of things, but it is my
understanding that it might rather be a bug in card's firmware. If so,
there is hardly anything that can be done about it, right? Shouldn't th=
e
driver provide a workaround in that case?

(Don't bother CCing me, I'm on the list.)

Regards,

--=20
Pierre Ynard
WTS #51 - No phone
"Une =E2me dans un corps, c'est comme un dessin sur une feuille de papi=
er."
