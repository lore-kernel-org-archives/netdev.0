From: Valdis.Kletnieks@vt.edu
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 16:18:17 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405122018.i4CKIHwB017258@turing-police.cc.vt.edu>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com> <20040512193349.GA14936@elte.hu> <Pine.LNX.4.58.0405121247011.11950@bigblue.dev.mdolabs.com>
            <20040512200305.GA16078@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-832646691P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Davide Libenzi <davidel@xmailserver.org>, Jeff Garzik <jgarzik@pobox.com>,
        Greg KH <greg@kroah.com>, Andrew Morton <akpm@osdl.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: Your message of "Wed, 12 May 2004 22:03:05 +0200."
             <20040512200305.GA16078@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_-832646691P
Content-Type: text/plain; charset="us-ascii"
Content-Id: <15995.1084393097.1@turing-police.cc.vt.edu>

On Wed, 12 May 2004 22:03:05 +0200, Ingo Molnar said:

> due to overflows. But we know that HZ is 1000 in the arch-dependent
> param.h, and in sched.c we use the HZ dependent variant:

That should read   we "know" that HZ is 1000....

How about this instead?

#if HZ == 1000
#define JIFFIES_TO_MSEC(x)  (x)
#else
#define JIFFIES_TO_MSEC(x) ((x) * 1000 / HZ)
#endif

That will DTRT if somebody changes HZ for their build, and still allow
us to avoud the *1000/1000 conversion for most builds.....

--==_Exmh_-832646691P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFAooaJcC3lWbTT17ARAopaAKDCMr9rL9FCL+yMbmfh32JTam9lzQCaAi46
PMHDTWHrIciffsZPR4rW778=
=Oras
-----END PGP SIGNATURE-----

--==_Exmh_-832646691P--
