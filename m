From: Daniele Venzano <venza@brownhat.org>
Subject: Re: [PATCH] sis900: Allocate rx replacement buffer before rx operation
Date: Fri, 20 Apr 2007 19:55:44 +0200
Message-ID: <53386A75-0A5F-4656-BEC8-981272454C31@brownhat.org>
References: <20070420135458.GB16191@hmsreliant.homelinux.net>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: multipart/signed; protocol="application/pgp-signature"; micalg=pgp-sha1; boundary="Apple-Mail-1--931433789"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Jeff Garzik <jgarzik@pobox.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.infomaniak.ch ([84.16.68.89]:46613 "EHLO
	smtp1.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993305AbXDTSKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Apr 2007 14:10:15 -0400
In-Reply-To: <20070420135458.GB16191@hmsreliant.homelinux.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-1--931433789
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed


Il giorno 20/apr/07, alle ore 15:54, Neil Horman ha scritto:

> Hey there-
> 	The sis900 driver appears to have a bug in which the receive routine
> passes the skbuff holding the received frame to the network stack  
> before
> refilling the buffer in the rx ring.  If a new skbuff cannot be  
> allocated, the
> driver simply leaves a hole in the rx ring, which causes the driver  
> to stop
> receiving frames and become non-recoverable without an rmmod/insmod  
> according to
> reporters.  This patch reverses that order, attempting to allocate  
> a replacement
> buffer first, and receiving the new frame only if one can be  
> allocated.  If no
> skbuff can be allocated, the current skbuf in the rx ring is  
> recycled, dropping
> the current frame, but keeping the NIC operational.
Yes, I had one report of a user actually hitting this, but it is  
quite hard to reproduce and I don't have continuos access anymore to  
my sis900 machine.
The patch seems fine by me.

> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: Daniele Venzano <venza@brownhat.org>

--
Daniele Venzano
http://www.brownhat.org


--Apple-Mail-1--931433789
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: =?ISO-8859-1?Q?Questa_=E8_un_messaggio_firmato_elettronicamente?=
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (Darwin)

iD8DBQFGKP6m2rmHZCWzV+0RAhVuAKCU9TDwnR6bENfR+laNcm37ItD3GQCgoTaP
NrEewmXQ1cXFRyopJUhY20U=
=LFJe
-----END PGP SIGNATURE-----

--Apple-Mail-1--931433789--
