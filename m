From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 2/4] caif: Add support for CAIF over CDC NCM
 USB interface
Date: Sun, 04 Dec 2011 13:18:36 -0500 (EST)
Message-ID: <20111204.131836.231887333540568891.davem@davemloft.net>
References: <1322993450-8802-1-git-send-email-sjur.brandeland@stericsson.com>
	<1322993450-8802-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, alexey.orishko@stericsson.com,
	eric.dumazet@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38056 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754614Ab1LDSSn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2011 13:18:43 -0500
In-Reply-To: <1322993450-8802-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Sun,  4 Dec 2011 11:10:48 +0100

> NCM 1.0 does not support anything but Ethernet framing, hence
> CAIF payload will be put into Ethernet frames.
>=20
> Discovery is based on fixed USB vendor 0x04cc (ST-Ericsson),
> product-id 0x230f (NCM). In this variant only CAIF payload is sent ov=
er
> the NCM interface.
>=20
> The CAIF stack (cfusbl.c) will when USB interface register first chec=
k if
> we got a CDC NCM USB interface with the right VID, PID.
> It will then read the device's Ethernet address and create a 'templat=
e'
> Ethernet TX header, using a broadcast address as the destination addr=
ess,
> and EthType 0x88b5 (802.1 Local Experimental - vendor specific).
>=20
> A protocol handler for 0x88b5 is setup for reception of CAIF frames f=
rom
> the CDC NCM USB interface.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Please make this feature a tristate and make the init and exit
routines executed via the normal modula_init()/module_exit()
mechanisms.

That way you don't need that dopey header file to export the
init and exit routines, and you don't need to ifdef crap up the
code CAIF code to invoke them.
