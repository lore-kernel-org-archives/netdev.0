From: Valdis.Kletnieks@vt.edu
Subject: Re: linux-next: zillions of lockdep whinges in include/net/sock.h:1408
Date: Sun, 24 Apr 2016 15:56:18 -0400
Message-ID: <176911.1461527778@turing-police.cc.vt.edu>
References: <43037.1461229555@turing-police.cc.vt.edu> <1461245496.7627.17.camel@edumazet-glaptop3.roam.corp.google.com> <5718DA71.7050902@stressinduktion.org> <20160424.143833.2292980084570149367.davem@davemloft.net> <571D14F8.6070306@stressinduktion.org>
 <1461527202.5535.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1461527778_3325P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461527202.5535.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1461527778_3325P
Content-Type: text/plain; charset=us-ascii

On Sun, 24 Apr 2016 12:46:42 -0700, Eric Dumazet said:

> >>> +	return !debug_locks ||
> >>> +	       lockdep_is_held(&sk->sk_lock) ||

> Issue here is that once lockdep detected a problem (not necessarily in
> net/ tree btw), your helper always 'detect' a problem, since lockdep
> automatically disables itself.

"D'Oh!" -- H. Simpson

I thought this patch looked suspect, but couldn't put my finger on it. The
reason why I got like 41,000 of them is because I built a kernel that has
lockdep enabled, but I have an out-of-tree module that doesn't init something,
so I get this:

[   48.898156] INFO: trying to register non-static key.
[   48.898157] the code is fine but needs lockdep annotation.
[   48.898157] turning off the locking correctness validator.

After which point, even with this patch, every time through it's still going to
explode.



--==_Exmh_1461527778_3325P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVx0k4QdmEQWDXROgAQLvPRAAk9iMCiM/gh3WKOq8QW4PL8R+aA+3H6GW
l7lDxrQMQFEBJlxWspr5qPWJu2RsT8iQNjs6hAF1FTZRWpM3BDhupKVvAGpmWutT
iIFXpTH+yaafl9OCvPh2emFb3rul4gUs5fwdubStM2eA6SweWSlli8xvzNHswqwx
bk3aWNHiTbjK/A9YbIOtnBNDngWsYtA5CgtuGEP7RJsaOYyQPVdx6L8mNzyInfGJ
CiPHRsoeqc21nNBWjd8ul2wz6SuVpv6BoCvKluSXXGpYfzMSXYjDsP3gGgJNV8Da
TX5xODCEORgHQ8XKU0WLgdj38aQCkrTWYg0Ivsne+3KF5wdQOokLNnax3knCn2rH
TY+3vQK7VNanoVfmb9JTwhUtGP2SVtpT7q/OKWY1Ng1xojz1QyKm+Zu5g+ok0Bb3
OwzgT+FflMZE9mrqCyOmDrkIg6+RclrT3fGz1yFA2zlYdhBAfnc8JdXDjSqQqCim
Xrgtn6Y/SszHemxkHUYoUcnE3FLoMIkWXxdTccA1OmuoSEfL4+0mVKZpNo+0vYGf
gadbL4oyXNkebMzMnxvRVVdud9HNWpAuQhXqwfAJa1I7eeOy8XCNk7HpyXRXY+xq
hhOBT0oTsD5xt1Cx7y4Ar4TF1EXoTUHI2ghmvi/TTrS3HF0gismHWe98Vwnsw/jr
7NZR3KAH21g=
=RnCQ
-----END PGP SIGNATURE-----

--==_Exmh_1461527778_3325P--
