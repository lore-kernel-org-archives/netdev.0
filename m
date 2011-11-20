From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH 5/5] tcp: skip cwnd moderation in TCP_CA_Open in
 tcp_try_to_open
Date: Sun, 20 Nov 2011 11:19:42 +0100
Message-ID: <90EF29F7-D4D0-4695-8D29-E2D37298A99A@comsys.rwth-aachen.de>
References: <1321469885-10885-1-git-send-email-ncardwell@google.com>
 <1321469885-10885-5-git-send-email-ncardwell@google.com>
 <alpine.DEB.2.00.1111170706330.23028@melkinpaasi.cs.helsinki.fi>
 <CADVnQymPTWsD0Hx060qYUMrFPxgQPdJWwPA9oDce6qMVL4tVpA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
 boundary="Apple-Mail=_60721C1A-BD39-43BF-B4B7-18498351C272";
 protocol="application/pgp-signature"; micalg=pgp-sha1
Cc: =?iso-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Nandita Dukkipati <nanditad@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Tom Herbert <therbert@google.com>,
	Carsten Wolff <carsten@wolffcarsten.de>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mta-1.ms.rz.RWTH-Aachen.DE ([134.130.7.72]:51110 "EHLO
	mta-1.ms.rz.rwth-aachen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752831Ab1KTKto (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Nov 2011 05:49:44 -0500
Received: from ironport-out-1.rz.rwth-aachen.de ([134.130.5.40])
 by mta-1.ms.rz.RWTH-Aachen.de
 (Sun Java(tm) System Messaging Server 6.3-7.04 (built Sep 26 2008))
 with ESMTP id <0LUY00EVRFCTSTJ0@mta-1.ms.rz.RWTH-Aachen.de> for
 netdev@vger.kernel.org; Sun, 20 Nov 2011 11:19:41 +0100 (CET)
Received: from [192.168.4.17] ([unknown] [79.132.249.16])
 by relay-auth-1.ms.rz.rwth-aachen.de
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec  9 2008))
 with ESMTPA id <0LUY001R6FCS9X00@relay-auth-1.ms.rz.rwth-aachen.de> for
 netdev@vger.kernel.org; Sun, 20 Nov 2011 11:19:41 +0100 (CET)
In-reply-to: <CADVnQymPTWsD0Hx060qYUMrFPxgQPdJWwPA9oDce6qMVL4tVpA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Apple-Mail=_60721C1A-BD39-43BF-B4B7-18498351C272
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain;
	charset=iso-8859-1

Hi Neal,

Am 19.11.2011 um 22:08 schrieb Neal Cardwell:

> On Thu, Nov 17, 2011 at 12:14 AM, Ilpo J=E4rvinen
> <ilpo.jarvinen@helsinki.fi> wrote:
>=20
>> I think it's intentional. Because of receiver lying bandwidth cheats =
all
>> unlimited undos are bit dangerous.
>=20
> If your concern is receivers lying, then there are other easy ways
> that a misbehaving receiver can get a sender to send too fast
> (e.g. cumulatively ACKing the highest sequence number seen,
> irrespective of holes). IMHO it would be a shame to penalize the vast
> majority of well-behaved users to plug one potential attack vector
> when there are other easy holes that an attacker would use.
>=20
>> Wouldn't it be enough if tcp max burst is increased to match IW (iirc =
we
>> had 3 still there as a magic number)?
>=20
> Yes, tcp_max_burst() returns tp->reordering now. Changing it to return
> max(tp->reordering, TCP_INIT_CWND) sounds good to me. I think that's
> an excellent idea in any case, regardless of the outcome of this undo
> discussion.

For my Phd thesis - based on the Linux reordering detection we =
implemented
an adaptive Version of TCP-NCR (RFC 4653) - we change tcp_max_burst() to
return TCP_INIT_CWND. If the reordering delay is high, tp->reordering is
high as well, allowing to send a huge burst. In 2008 John Heffner* =
changed
tcp_max_burst() to return tp->reordering according to problem for =
reordering
on the reverse path. However, I never was be able to reproduce old =
problem...
Due to my experience I recommend to use TCP_INIT_CWND directly.

(*)http://git.kernel.org/linus/dd9e0dda66ba38a2ddd140 =
5ac279894260dc5c36.

>=20
> However, I don't think this is sufficient for request-response
> protocols (e.g. RPC) running over long-lived connections over a path
> with a large bandwidth-delay product. In such cases, the cwnd will
> grow quite large (hundreds of packets). The DSACKs will often arrive
> after the entire response is sent, so that cwnd moderation will
> typically pull the cwnd down to 3 (or, with your proposal, 10)
> packets. IMHO that seems like an unnecessarily steep price to pay.
>=20
> neal
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail=_60721C1A-BD39-43BF-B4B7-18498351C272
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename=signature.asc
Content-Type: application/pgp-signature;
	name=signature.asc
Content-Description: Message signed with OpenPGP using GPGMail

-----BEGIN PGP SIGNATURE-----

iEYEARECAAYFAk7I1D8ACgkQdyiq39b9uS4nIgCgmFK27X7tX49bNuCjxUnS53p2
3Y8AoJx2l2RaJz5setPSWUWn0Yuz28Z1
=V5Bs
-----END PGP SIGNATURE-----

--Apple-Mail=_60721C1A-BD39-43BF-B4B7-18498351C272--
