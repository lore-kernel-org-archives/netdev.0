From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Thu, 28 Apr 2011 08:11:15 +0200
Message-ID: <B35A6FDF-714A-4226-AFF4-D12ECCD4A152@comsys.rwth-aachen.de>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
 <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
 <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
 <201104271157.49386.carsten@wolffcarsten.de>
 <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
 <BANLkTi=i5ZftuL++ORuy=n_yM_futWYoZw@mail.gmail.com>
 <BANLkTinsHuP3XSSghfpYET=os9VcJ3FRDA@mail.gmail.com>
 <BANLkTin5dsubSjOhz3enOjubfVVk6uiNbQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-2--753639113
Content-Transfer-Encoding: 7bit
Cc: Dominik Kaspar <dokaspar.ietf@gmail.com>,
	Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:37769 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752746Ab1D1GLS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2011 02:11:18 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LKC00J4QMIT2590@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Thu, 28 Apr 2011 08:11:17 +0200 (CEST)
Received: from [192.168.4.14] ([unknown] [77.109.115.94])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LKC005LUMITT950@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Thu, 28 Apr 2011 08:11:17 +0200 (CEST)
In-reply-to: <BANLkTin5dsubSjOhz3enOjubfVVk6uiNbQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-2--753639113
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii


Am 27.04.2011 um 23:41 schrieb Yuchung Cheng:

> AFAIK, FACK is disabled throughout the life of the connection after
> sender detects reordering degree > 3.

Right.

> 
> But Alex said the reordering has some bugs. I suspect these bugs may
> affect FACK/sack auto-tuning.

No. It affects reordering detection only. 

> Maybe Alex could describe the reordering
> bugs?
> 

Yes, I can. With DSACK, you have two cases. DSACK below and above SEG.ACK.
DSACK below SEG.ACK is the come case. However, Linux doesn't calculate a
reordering extent in this case. We will fix this. In the other case, DSACK
above SEG.ACK, Linux quantifies the reordering as the distance between the
received DSACK and snd_fack. However, this is only correct if the reordering
delay is greater the RTT. We will fix that too.

As a result, in the first case, we waste the opportunity to calculate an
extent (loosing performance). In the second case we overestimate the
reordering.

Alex

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-2--753639113
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk25BQMACgkQdyiq39b9uS4GBgCfRGUv0ThShsqPqmea02oeUzBN
Wx0An2rWIXYQgPyA5ofkFvQzx9gPxZBq
=BNwD
-----END PGP SIGNATURE-----

--Apple-Mail-2--753639113--
