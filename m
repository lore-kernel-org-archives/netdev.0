From: Alexander Zimmermann <alexander.zimmermann@comsys.rwth-aachen.de>
Subject: Re: [PATCH] tcp: Implement a two-level initial RTO as per draft RFC
 2988bis-02.
Date: Thu, 19 May 2011 08:52:10 +0200
Message-ID: <8C5DF277-320D-4DEB-A133-EEC301DE58DC@comsys.rwth-aachen.de>
References: <1305771744-83951-1-git-send-email-tsunanet@gmail.com>
 <20110518.223622.1525088601595365235.davem@davemloft.net>
 <BANLkTinEN_=jSCw4qR1PqtWaQ+07OMq7tg@mail.gmail.com>
 <20110519.001426.2119532755281545481.davem@davemloft.net>
 <BANLkTikQEq9+YkJHcTe3PWnRvh7AN=VVWA@mail.gmail.com>
 <9DC9A4D5-8E16-4361-B323-C92D563171A1@comsys.rwth-aachen.de>
 <BANLkTimVMYC5rzizaM+3dReG14obxGL=Bw@mail.gmail.com>
 <C70B920C-6176-481B-B6D2-E52769291EBC@comsys.rwth-aachen.de>
 <BANLkTiku9KTHCm59cib5KY8mz0ewSLsHFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg=pgp-sha1; boundary=Apple-Mail-35-1063216526
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, kuznet@ms2.inr.ac.ru,
	pekkas@netcore.fi, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, hagen@jauu.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: tsuna <tsunanet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <BANLkTiku9KTHCm59cib5KY8mz0ewSLsHFQ@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--Apple-Mail-35-1063216526
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=us-ascii


Am 19.05.2011 um 08:42 schrieb tsuna:

> On Wed, May 18, 2011 at 11:36 PM, Alexander Zimmermann
> <alexander.zimmermann@comsys.rwth-aachen.de> wrote:
>> If you set the initRTO=0.1s, it's good for me but bad for the rest of the
>> world. That's the difference.
>> 
>> Or do you want to implement a lower barrier of 1sec so that you can ensure
>> that nobody set the initRTO lower than 1s?
> 
> Oh, I see.  Yes, there is a lower bound (and an upper bound) on what
> values the kernel will accept as initRTO.  In the patch "Implement a
> two-level initial RTO as per draft RFC 2988bis-02" above, I re-used
> TCP_RTO_MIN and TCP_RTO_MAX in net/ipv4/sysctl_net_ipv4.c in order to
> prevent users from setting a minRTO that's outside this range.  They
> are defined as follows in tcp.h:
> 
> #define TCP_RTO_MAX     ((unsigned)(120*HZ))
> #define TCP_RTO_MIN     ((unsigned)(HZ/5))
> 
> So we're talking about a [200ms ; 120s] range no matter what.

Why is 200ms a valid lower bound for initRTO? I'm aware of
measurements that 1s is save for Internet, but I don't know of any
studies that 200ms is save... 

> 
> -- 
> Benoit "tsuna" Sigoure
> Software Engineer @ www.StumbleUpon.com

//
// Dipl.-Inform. Alexander Zimmermann
// Department of Computer Science, Informatik 4
// RWTH Aachen University
// Ahornstr. 55, 52056 Aachen, Germany
// phone: (49-241) 80-21422, fax: (49-241) 80-22222
// email: zimmermann@cs.rwth-aachen.de
// web: http://www.umic-mesh.net
//


--Apple-Mail-35-1063216526
content-type: application/pgp-signature; x-mac-type=70674453;
	name=PGP.sig
content-description: Signierter Teil der Nachricht
content-disposition: inline; filename=PGP.sig
content-transfer-encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.17 (Darwin)
Comment: GPGTools - http://gpgtools.org

iEYEARECAAYFAk3UvhsACgkQdyiq39b9uS47LQCeOTN8hzVZCY1fUd5Uj6h/PPZJ
mQcAoOyDKx6mSIrxGO5SZ+z72zAMVPlP
=G2Qm
-----END PGP SIGNATURE-----

--Apple-Mail-35-1063216526--
