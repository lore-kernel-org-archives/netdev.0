From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net-next-2.6 PATCH 6/9] vxge: Check if FCS stripping is disabled
 by the firmware.
Date: Mon, 05 Oct 2009 15:04:32 +0200
Message-ID: <4AC9EEE0.5000601@gmail.com>
References: <Pine.GSO.4.10.10910050755480.9377-100000@guinness>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, support@neterion.com
To: Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45011 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753953AbZJENFS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2009 09:05:18 -0400
In-Reply-To: <Pine.GSO.4.10.10910050755480.9377-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sreenivasa Honnur a =E9crit :
> - Added a function to check if FCS stripping is disabled by the firmw=
are, if
>   it is not disabled fail driver load.
>=20
> - By default FCS stripping is disabled by the firmware. With this ass=
umption
>   driver decrements the indicated packet length by 4 bytes(FCS length=
).
>=20
> - This patch ensures that FCS stripping is disabled during driver loa=
d time.
>=20
> Signed-off-by: Sreenivasa Honnur <sreenivasa.honnur@neterion.com>

What the big deal about FCS not being stripped ?

Denying driver load for this litle detail seems very hard.
You could issue a warning if there is a performance hit, but allow the =
driver
to function.

If this adapter has the ability to disable/enable it at firmware level,
you might replace

pkt_length -=3D ETH_FCS_LEN;

by :

pkt_length -=3D adapter->fcs_length; =20

Granted you initialized adapter->fcs_length to 0 or 4 depending on firm=
ware setup.


