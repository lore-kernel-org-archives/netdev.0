From: Valdis.Kletnieks@vt.edu
Subject: Re: MSEC_TO_JIFFIES is messed up...
Date: Wed, 12 May 2004 15:47:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200405121947.i4CJlJm5029666@turing-police.cc.vt.edu>
References: <20040512020700.6f6aa61f.akpm@osdl.org> <20040512181903.GG13421@kroah.com> <40A26FFA.4030701@pobox.com>
            <20040512193349.GA14936@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_-922413546P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, Greg KH <greg@kroah.com>,
        Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: Your message of "Wed, 12 May 2004 21:33:49 +0200."
             <20040512193349.GA14936@elte.hu>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--==_Exmh_-922413546P
Content-Type: text/plain; charset=us-ascii

On Wed, 12 May 2004 21:33:49 +0200, Ingo Molnar said:
> 
> * Jeff Garzik <jgarzik@pobox.com> wrote:
> 
> > >Woah, that's new.  And wrong.  The code in include/asm-i386/param.h that
> > >says:
> > >	# define JIFFIES_TO_MSEC(x)     (x)
> > >	# define MSEC_TO_JIFFIES(x)     (x)
> > >
> > >Is not correct.  Look at kernel/sched.c for verification of this :)
> > 
> > 
> > Yes, that is _massively_ broken.
> 
> why is it wrong?

If the kernel jiffie is anything other than exactly 1 msec, you're screwed... 

[/usr/src/linux-2.6.6-mm1]2 find include -name '*.h' | xargs egrep '#define HZ '
include/asm-ppc64/param.h:#define HZ 100
include/asm-mips/param.h:#define HZ 100
include/asm-mips/mach-dec/param.h:#define HZ (1 << LOG_2_HZ)
include/asm-x86_64/param.h:#define HZ 100
include/asm-ppc/param.h:#define HZ 100
include/asm-m68k/param.h:#define HZ 100
include/asm-m68knommu/param.h:#define HZ 1000
include/asm-m68knommu/param.h:#define HZ 100
include/asm-m68knommu/param.h:#define HZ 100
include/asm-m68knommu/param.h:#define HZ 100
include/asm-m68knommu/param.h:#define HZ 100
include/asm-m68knommu/param.h:#define HZ 100
include/asm-m68knommu/param.h:#define HZ 100
include/asm-m68knommu/param.h:#define HZ 50
include/asm-m68knommu/param.h:#define HZ 100
include/asm-parisc/param.h:#define HZ 100
include/asm-um/param.h:#define HZ 100
include/asm-sparc/param.h:#define HZ 100
include/asm-s390/param.h:#define HZ 100
include/asm-i386/param.h:#define HZ 100
include/asm-h8300/param.h:#define HZ 100
include/asm-sparc64/param.h:#define HZ 100
include/asm-cris/param.h:#define HZ 100
include/asm-sh/param.h:#define HZ 100


--==_Exmh_-922413546P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.4 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFAon9GcC3lWbTT17ARAigPAKCCSPWwcCkQWibTwH1yc2UpF9xdlQCcCafE
oGCyNTmsGJeq1az6FzsK43o=
=4uGi
-----END PGP SIGNATURE-----

--==_Exmh_-922413546P--
