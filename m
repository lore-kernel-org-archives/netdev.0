From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2010-05-11 - dies in pm_qos_update_request()
Date: Thu, 13 May 2010 10:34:38 -0400
Message-ID: <4793.1273761278@localhost>
References: <201005120149.o4C1n7P4002637@imap1.linux-foundation.org> <5525.1273693962@localhost>
            <201005122307.20860.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1273761278_3844P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Mark Gross <mgross@linux.intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Wed, 12 May 2010 23:07:20 +0200."
             <201005122307.20860.rjw@sisk.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1273761278_3844P
Content-Type: text/plain; charset=us-ascii

On Wed, 12 May 2010 23:07:20 +0200, "Rafael J. Wysocki" said:
> On Wednesday 12 May 2010, Valdis.Kletnieks@vt.edu wrote:
> > On Tue, 11 May 2010 18:21:22 PDT, akpm@linux-foundation.org said:
> > > The mm-of-the-moment snapshot 2010-05-11-18-20 has been uploaded to
> > > 
> > >    http://userweb.kernel.org/~akpm/mmotm/
> > 
> > Dell Latitude E6500, x86_64 kernel.
> > 
> > Died a horrid death at boot in the e1000e driver.  Seems to be
> > something in linux-next.patch. Didn't get a netconsole trace for obvious
> > reasons...
> > 
> > Copied-by-hand traceback:
> > pm_qos_update_request()+0x22
> > e1000_configure+0x478
> > e1000_open_device+0xee
> > ? _raw_notifier_call_chain+0xf
> > __dev_open+0xec
> > dev_open+0x1b
> > netpoll_setup+0x28b
> > init_netconsole+0xbc
> > 
> > I suspect this commit:
> > 
> > commit 23606cf5d1192c2b17912cb2ef6e62f9b11de133
> > Author: Rafael J. Wysocki <rjw@sisk.pl>
> > Date:   Sun Mar 14 14:35:17 2010 +0000
> > 
> >     e1000e / PCI / PM: Add basic runtime PM support (rev. 4)
> 
> No, I don't think so.  I'm running -rc6 with this patch applied on a box with
> e1000e and it works just fine.
> 
> Please try to revert this one instead:
> 
> http://git.kernel.org/?p=linux/kernel/git/rafael/suspend-2.6.git;a=patch;h=ed77134bfccf5e75b6cbadab268e559dbe6a4ebb

Confirming - reverting that patch and doing the build fixup results in a
kernel that doesn't blow up in the e1000e driver...

--==_Exmh_1273761278_3844P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL7A3+cC3lWbTT17ARAm3PAKDAE87ziAO2wE6RkIcdkh3geTyBNgCeNxGQ
pN4PRpx1eTZUoKSO5fvSmfo=
=Zq3X
-----END PGP SIGNATURE-----

--==_Exmh_1273761278_3844P--
