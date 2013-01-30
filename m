From: "voncken" <cedric.voncken@acksys.fr>
Subject: RE: Gianfar : Drop a long frame
Date: Wed, 30 Jan 2013 17:27:22 +0100
Message-ID: <001e01cdff06$ae4de6c0$0ae9b440$@acksys.fr>
References: <001a01cdfeef$cdc5bee0$69513ca0$@acksys.fr> <51094280.8060701@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "'Claudiu Manoil'" <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out06.msg.oleane.net ([62.161.7.4]:49886 "EHLO
	smtp-out06.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754368Ab3A3QsO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jan 2013 11:48:14 -0500
Received: from smtp04.msg.oleane.net (smtp04.mail.priv [172.17.20.113])
	by smtp-out06.msg.oleane.net with ESMTP id r0UGmBgA009216
	for <netdev@vger.kernel.org>; Wed, 30 Jan 2013 17:48:12 +0100
In-Reply-To: <51094280.8060701@freescale.com>
Content-Language: fr
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Message d'origine-----
De=A0: Claudiu Manoil [mailto:claudiu.manoil@freescale.com]=20
Envoy=E9=A0: mercredi 30 janvier 2013 16:56
=C0=A0: voncken
Cc=A0: netdev@vger.kernel.org
Objet=A0: Re: Gianfar : Drop a long frame

On 1/30/2013 3:43 PM, voncken wrote:
> 	Hi Claudiu,
>
> 	I have a problem with the gianfar driver.
>
> 	My test conditions are:
> 		- Disable rxvlan hardware acceleration (ethtool -K ethx
rxvlan off)
> 		- Receive frame contains a VLAN tag and with a frame len set
to the=20
> MTU (1500 bytes).
>
> 	In this condition, when I received a long frame the bdp->length is=20
> set to 1538 bytes.
> 	I guess it is composed of:
> 		1500 bytes: L3 data bytes
> 		 + 14 bytes:  Ethernet header
> 		 + 4 bytes:  Vlan Tag header
> 		 + 8 bytes: FCB structure size GMAC_FCB_LEN
> 		 + 8 bytes: eTSEC padding
> 		 + 4 bytes: Frames CRC (FCS)
>
> 	The Maximum frame len is set to 1536 because the function=20
> gfar_change_mtu does not integrate the FCS in the computed frame size=
=2E
> 	In this condition this frame is dropped with the test line 2792=20
> function gfar_clean_rx_ring
> 		if (unlikely(!(bdp->status & RXBD_ERR) &&
> 				bdp->length > priv->rx_buffer_size))
> 			bdp->status =3D RXBD_LARGE;
> =09
> 	How I can receive this frame correctly?
> =09
> 	Best regards
>
> Cedric Voncken | R&d Engineer

Hi Cedric Voncken,
Is the 802.1Q support activated on the receiving host? (see
CONFIG_VLAN_8021Q)

Hi Claudiu,=20

YEs the CONFIG_VLAN_8021Q is enable on the receiving host, that work
correctly if RXVLAN is set to on (ethtool -K ethx rxvlan off)
I try with the linux kernel 3.3.8.

Regards.
