From: Volker Lendecke <Volker.Lendecke@SerNet.DE>
Subject: Re: maximum buffer size for splice(2) tcp->pipe?
Date: Wed, 14 Jan 2009 11:03:30 +0100
Message-ID: <E1LN2Vu-00DluN-6Z@intern.SerNet.DE>
References: <E1LKrp3-004Tub-IR@intern.SerNet.DE> <20090113123702.ad29cd13.akpm@linux-foundation.org> <496D2078.9080302@cosmosbay.com> <E1LN0MC-00DaJs-M2@intern.SerNet.DE> <496DACBE.3030701@cosmosbay.com>
Reply-To: Volker.Lendecke@SerNet.DE
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="32u276st3Jlj2kUU"
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, Steven French <sfrench@us.ibm.com>,
	Jens Axboe <jens.axboe@oracle.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.SerNet.de ([193.175.80.2]:54738 "EHLO mail.SerNet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755796AbZANJ60 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 04:58:26 -0500
Content-Disposition: inline
In-Reply-To: <496DACBE.3030701@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--32u276st3Jlj2kUU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jan 14, 2009 at 10:13:34AM +0100, Eric Dumazet wrote:
> for (;;) {
> 	struct pollfd pfd;
> 	pfd.fd = socket;
> 	pfd.events = POLLIN;
> 	if (poll(&pfd, 1, -1) != 1)
> 		continue;
> 	res = splice(socket, NULL, pipefds[1], NULL, 65536, SPLICE_F_MOVE|SPLICE_F_NONBLOCK);
> 	if (res > 0)
> 		nwritten = splice(pipefds[0], NULL, file_fd, NULL, res, SPLICE_F_MOVE|SPLICE_F_MORE);
> }

Doesn't this reduce performance again? I thought the whole
point of splice() was to increase performance by avoiding
memory copies. If I have to do a poll syscall for each call
to splice, doesn't the context switch eat that performance
advantage again?

Or was splice designed only for multi-threaded applications
(which at least Samba is not)?

Volker

--32u276st3Jlj2kUU
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQFJbbhxbsgDfmnSbrYRArUlAKCNJN/kZsH3qvIYr463z1dlJbuFnQCfQ8qv
alcUmIhEtdEGjlJBBkzCQt0=
=FrZY
-----END PGP SIGNATURE-----

--32u276st3Jlj2kUU--
