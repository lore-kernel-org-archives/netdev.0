From: Alexander Zimmermann <zimmermann@nets.rwth-aachen.de>
Subject: Re: Linux TCP's Robustness to Multipath Packet Reordering
Date: Wed, 27 Apr 2011 18:36:02 +0200
Message-ID: <D0D2412D-2D30-4051-B346-32D20858BC92@nets.rwth-aachen.de>
References: <BANLkTimpgXCpweZKCihCQkLjSZw5zL4=Pg@mail.gmail.com>
 <BANLkTikjcd6ZAF5wH_8CKA_OCrfprGokmw@mail.gmail.com>
 <BANLkTikoQfbSxnJi_OR+N6sa5iVNcTO6Ug@mail.gmail.com>
 <201104271157.49386.carsten@wolffcarsten.de>
 <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-5--802551810
Content-Transfer-Encoding: 7bit
Cc: Carsten Wolff <carsten@wolffcarsten.de>,
	John Heffner <johnwheffner@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	Lennart Schulte <Lennart.Schulte@comsys.rwth-aachen.de>,
	Arnd Hannemann <arnd@arndnet.de>
To: Dominik Kaspar <dokaspar.ietf@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:51122 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756236Ab1D0RGI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2011 13:06:08 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LKB00EOEKS4RAC0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 27 Apr 2011 18:36:04 +0200 (CEST)
Received: from [192.168.4.14] ([unknown] [77.109.115.94])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LKB00511KS3PJ70@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Wed, 27 Apr 2011 18:36:04 +0200 (CEST)
In-reply-to: <BANLkTimNC9DgWtkTTtjC_v0FsxzvBMsQGw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-5--802551810
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii

Hi,

Am 27.04.2011 um 18:22 schrieb Dominik Kaspar:

> Hi Carsten,
> 
> Thanks for your feedback. I made some new tests with the same setup of
> packet-based forwarding over two emulated paths (600 KB/s, 10 ms) +
> (400 KB/s, 100 ms). In the first experiments, which showed a step-wise
> adaptation to reordering, SACK, DSACK, and Timestamps were all
> enabled. In the experiments, I individually disabled these three
> mechanisms and saw the following:
> 
> - Disabling timestamps causes TCP to never adjust to reordering at all.

Reordering detection with DSACK is broken in Linux. We will fix that in
a couple of weeks...

> - Disabling SACK allows TCP to adapt very rapidly ("perfect" aggregation!).

If you disable SACK, you will use the NewReno detection

> - Disabling DSACK has no obvious impact (still a step-wise throughput).

If Timestamps are enabled, Linux use Timestamps for detection. Regardless
of DSACK. Timestamp detection is quicker. See RFC3522. (However, in case
of an spurious FRet it's not so dramatical. In case of an Spurious RTO,
you can avoid the go-back-n behavior)


> 
> Is there an explanation for why turning off SACK can be beneficial in
> the presence of packet reordering? That sounds pretty
> counter-intuitive to me... I thought SACK=1 always performs better
> than SACK=0. The results are also illustrated in the following plot.
> For each setting, there are three runs, which all exhibit a similar
> behavior:
> 
> http://home.simula.no/~kaspar/static/mptcp-emu-wlan-hspa-02-sack.png
> 
> Greetings,
> Dominik
> 

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-5--802551810
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk24RfMACgkQdyiq39b9uS6nTgCg7xbgYBfCzFJu/0v3VLAv3+Cq
+T0AoNZ4B6+6D+00p4JC9TKxYtbClTJs
=454f
-----END PGP SIGNATURE-----

--Apple-Mail-5--802551810--
