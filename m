From: Sven Eckelmann <sven@narfation.org>
Subject: Re: Re: Re: [B.A.T.M.A.N.] [PATCH] net: fix possible deadlocks in rtnl_trylock/unlock
Date: Mon, 03 Dec 2012 21:50:16 +0100
Message-ID: <2405524.vnLJteJr23@sven-laptop.home.narfation.org>
References: <1354382991-31350-1-git-send-email-siwu@hrz.tu-chemnitz.de> <20121201200153.GA1002@pandem0nium> <20121203200906.GJ27828@ritirata.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1669944.gnPz9kdrbm"; micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	b.a.t.m.a.n@lists.open-mesh.org, netdev@vger.kernel.org,
	davem@davemloft.net, Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
To: Antonio Quartulli <ordex@autistici.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:40910 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009Ab2LCUu2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2012 15:50:28 -0500
In-Reply-To: <20121203200906.GJ27828@ritirata.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nextPart1669944.gnPz9kdrbm
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

On Monday 03 December 2012 21:09:06 Antonio Quartulli wrote:
> But still we have the problem in batman-adv (as Sven pointed out in a
> previous email) that tries to unregister a device in that "critical
> window".
> 
> Exporting __rtnl_unlock() would solve the issue in this case.
> 
> If you think the bridge code should not end up in such situation, what if
> Simon resends the patch with only the __rtnl_unlock() exportation and the
> change in batman-adv?

I personally have big doubts about the removal of the second half of the 
unregister. Doesn't sound like the best idea. This would result in side 
effects... one of them for example would be the possible deadlock scenario 
moved to the other users of rtnl_trylock which don't unregister a device 
inside their critical section.... so either you do it always this way when 
using rtnl_trylock or it will break. I don't want to imagine other problems 
caused by this change.

Kind regards,
	Sven
--nextPart1669944.gnPz9kdrbm
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQvRCIAAoJEF2HCgfBJntGuoIQANMQ1t6a4QOtTQaOtunLmYGT
aEBfABjiF3m2ET3oScdgtH9cueNcxVTtSC54UAgCtGAKHVyNDqrAun9q3NRBIOjg
CUsTSkKc8h4syjfTVb8E6dhJvOF+Gj2gHhXWcairGc9OciSZEQfI2Iigu4g97ybo
UtpgfbLaym0gmLjMtGhetPYnQp9DVEhT27ljN3zlZTzoJQVwDVrF3+neW3a4ATx2
fHZB4eUWXs13DKh3fTv99D/ihfhdyyW3+KD9P0//qbIrNRONBEpkuvB+dxOPHzYw
hH39nzQtOwFOUob1iLwlR3UiyTWSfIn5nbZiCP7GCkSE+1I9KxyyfJN0WmJoQFFR
RGauCQk/1jOrxbzbVMQNEfvydeSQEmLy2cecsA3ZwXFo1puBucQahlMV+Ycg9Y58
aPqPbPuIeNMeYI4fserzxFIiqdrrJIn6fiVed0c4cICLbZnkJM2hVddkwcFjQxRu
DUBn//IKmpUaDY3SKXnjspThEFZS4xvDGfyz/MiM4lQBM4i4QaEOhl7bSc203K5x
ugmMP0HV47lUC0xGnGwSSu3UcEtIfGZlc5OqrwmPftFAjnW9iJlAnLJqFyReHcxH
uQpahbhhsDFMAc1XytY8AH08ijUjwVhBq8Ekhe6XMuxTpYAZP860ngP5dj1fbwa6
vLgQDXmeRgGm4m+dba/o
=52EV
-----END PGP SIGNATURE-----

--nextPart1669944.gnPz9kdrbm--
