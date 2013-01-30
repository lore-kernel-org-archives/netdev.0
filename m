From: "voncken" <cedric.voncken@acksys.fr>
Subject: Gianfar : Drop a long frame
Date: Wed, 30 Jan 2013 14:43:36 +0100
Message-ID: <001a01cdfeef$cdc5bee0$69513ca0$@acksys.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "'Claudiu Manoil'" <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.msg.oleane.net ([62.161.7.1]:44853 "EHLO
	smtp-out03.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082Ab3A3OEG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 09:04:06 -0500
Received: from smtp02.msg.oleane.net (smtp02.mail.priv [172.17.20.111])
	by smtp-out03.msg.oleane.net with ESMTP id r0UE42JM011065
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 15:04:03 +0100
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	Hi Claudiu,=20

	I have a problem with the gianfar driver.

	My test conditions are:
		- Disable rxvlan hardware acceleration (ethtool -K ethx
rxvlan off)
		- Receive frame contains a VLAN tag and with a frame len set
to the MTU (1500 bytes).

	In this condition, when I received a long frame the bdp->length is
set to 1538 bytes.=20
	I guess it is composed of:
		1500 bytes: L3 data bytes
		 + 14 bytes:  Ethernet header=20
		 + 4 bytes:  Vlan Tag header=20
		 + 8 bytes: FCB structure size GMAC_FCB_LEN
		 + 8 bytes: eTSEC padding
		 + 4 bytes: Frames CRC (FCS)

	The Maximum frame len is set to 1536 because the function
gfar_change_mtu does not integrate the FCS in the computed frame size.
	In this condition this frame is dropped with the test line 2792
function gfar_clean_rx_ring=20
		if (unlikely(!(bdp->status & RXBD_ERR) &&
				bdp->length > priv->rx_buffer_size))
			bdp->status =3D RXBD_LARGE;
=09
	How I can receive this frame correctly?
=09
	Best regards

Cedric Voncken | R&d Engineer
-----------------------------------------------------------------------=
-----
------------------------------
T : +33 1 30 56 46 52=20
cedric.voncken@acksys.fr | www.acksys.fr
-----------------------------------------------------------------------=
-----
------------------------------

=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=20
ZA Val Joyeux - 10 rue des Entrepreneurs - 78450 VILLEPREUX - France
-----------------------------------------------------------------------=
-----
----------
