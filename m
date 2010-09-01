From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: net-next-2.6 [PATCH 1/1] tcp: add missing initial window (RFC
	3390) for tcp_output
Date: Wed, 01 Sep 2010 09:06:10 +0200
Message-ID: <428BF15F-19DC-459A-B54A-EC273ECF537E@comsys.rwth-aachen.de>
References: <1283145794-5615-1-git-send-email-gerrit@erg.abdn.ac.uk>
 <1283145794-5615-2-git-send-email-gerrit@erg.abdn.ac.uk>
 <1283145794-5615-3-git-send-email-gerrit@erg.abdn.ac.uk>
 <1283145794-5615-4-git-send-email-gerrit@erg.abdn.ac.uk>
 <alpine.DEB.2.00.1008301557590.31318@wel-95.cs.helsinki.fi>
 <20100901052355.GA5379@gerrit.erg.abdn.ac.uk>
 <20100901053443.GB5379@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-8-74892337
Content-Transfer-Encoding: 7bit
Cc: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-2.ms.rz.RWTH-Aachen.DE ([134.130.7.73]:60999 "EHLO
	mta-2.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752767Ab0IAHGH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 03:06:07 -0400
Received: from ironport-out-2.rz.rwth-aachen.de ([134.130.5.41])
 by mta-2.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0L82000943Q5KB30@mta-2.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Wed, 01 Sep 2010 09:06:05 +0200 (CEST)
Received: from [137.226.12.62] ([unknown] [137.226.12.62])
 by relay-auth-2.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0L820073H3OVOV60@relay-auth-2.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Wed, 01 Sep 2010 09:06:05 +0200 (CEST)
In-reply-to: <20100901053443.GB5379@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-8-74892337
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii

Hi Gerrit,

Am 01.09.2010 um 07:34 schrieb Gerrit Renker:

> Please can you have a look, I have checked it, appears to be correct
> and compiles cleanly. Thanks again to Ilpo.
> 
>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Patch <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
> tcp: update also tcp_output with regard to RFC 5681
> 
> Thanks to Ilpo Jarvinen, his updates also the initial window
> setting for tcp_output with regard to RFC 5681.
> 
> Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
> ---
> net/ipv4/tcp_output.c |   10 +++-------
> 1 file changed, 3 insertions(+), 7 deletions(-)
> 
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -225,15 +225,11 @@ void tcp_select_initial_window(int __spa
> 	}
> 
> 	/* Set initial window to value enough for senders,
> -	 * following RFC2414. Senders, not following this RFC,
> -	 * will be satisfied with 2.
> +	 * following RFC5681 (which updates RFC3390).

In IETF sense, RFC5681 doesn't update RFC3390.

Alex


> 	 */
> 	if (mss > (1 << *rcv_wscale)) {
> -		int init_cwnd = 4;
> -		if (mss > 1460 * 3)
> -			init_cwnd = 2;
> -		else if (mss > 1460)
> -			init_cwnd = 3;
> +		int init_cwnd = rfc3390_bytes_to_packets(mss);
> +
> 		/* when initializing use the value from init_rcv_wnd
> 		 * rather than the default from above
> 		 */
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22221
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-8-74892337
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (Darwin)

iEYEARECAAYFAkx9+2IACgkQdyiq39b9uS5bTACgqb4fmIpVG7iQUL/Ea9OxyRQA
rtYAoNJU4F8h75cyM0ze6ovwoxHfa6bW
=m3Uk
-----END PGP SIGNATURE-----

--Apple-Mail-8-74892337--
