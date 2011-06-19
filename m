From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Sun, 19 Jun 2011 17:38:10 +0200
Message-ID: <C040825C-480A-46C6-AF32-76D90717BA06@comsys.rwth-aachen.de>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
 <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
 <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
 <201104271157.49386.carsten@wolffcarsten.de>
 <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
 <BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com>
 <BANLkTinsHuP3XSSghfpYET=os9VcJ3FRDA@mail.gmail.com>
 <BANLkTin5dsubSjOhz3enOjubfVVk6uiNbQ@mail.gmail.com>
 <B35A6FDF-714A-4226-AFF4-D12ECCD4A152@comsys.rwth-aachen.de>
 <BANLkTinueBFkVmR-Hd6d1Yojt+gsAV9PYw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-2--521791559
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yuchung Cheng <ycheng@google.com>,
	Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:43884 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754315Ab1FSPiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 11:38:11 -0400
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LN1004NJNFLA690@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sun, 19 Jun 2011 17:38:09 +0200 (CEST)
Received: from [137.226.12.53] ([unknown] [137.226.12.53])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LN10092DNFIBG60@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Sun, 19 Jun 2011 17:38:09 +0200 (CEST)
In-reply-to: <BANLkTinueBFkVmR-Hd6d1Yojt+gsAV9PYw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-2--521791559
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii

Hi,

Am 19.06.2011 um 17:22 schrieb Dominik Kaspar:

> Hello again,
> 
> I have another question to Linux TCP and packet reordering. What
> exactly happens, when a packet is so much delayed (but not causing a
> timeout), that it gets overtaken by a retransmitted version of itself?
> It seems to me that this results in "SACK reneging", but I don't
> really understand why...

in theory, you can detect this case with a combination of DSACK
and timestamps. However, in practice a reordering delay greater than
RTT will likely case an RTO (see RFC4653). IMO, if you have an packet
reordering with an delay greater that the RTT, you have much more problems  
that SACK reneging

> 
> The simplified situation goes this:
> - Segment A gets sent and very much delayed (but not causing RTO)
> - Segments B, C, D cause dupACKs
> - Segment A_ret is retransmitted and ACKed (sent over new path)
> - Some more segments E, F, ... are sent and ACKed
> - Segment A (the delayed one) arrives at the receiver.
> - Now what exactly happens next...?

Receiver sends a DSACK

> 
> I use default Linux TCP (with sack=1, dsack=1, fack=1, timestamps=1,
> ...) and the above described series of events is cause why
> transparently forwarding IP packets over multiple paths with RTTs of
> 10 and 100 milliseconds.
> 
> I'd appreciate your help - best regards,
> Dominik

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-2--521791559
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk3+F+IACgkQdyiq39b9uS5vHwCfZz4VNB9oXqEGpMFBU02sxvTn
QJoAoK+jcwhbajHQgLfNGbBx0oestqZf
=JM3m
-----END PGP SIGNATURE-----

--Apple-Mail-2--521791559--
