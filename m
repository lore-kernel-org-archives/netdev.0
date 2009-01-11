From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Sun, 11 Jan 2009 11:48:22 -0500
Message-ID: <58054.1231692502@turing-police.cc.vt.edu>
References: <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com> <20090109.140422.60087297.davem@davemloft.net> <43805.1231672258@turing-police.cc.vt.edu> <20090111.040842.86784676.davem@davemloft.net> <1231676698.25018.147.camel@macbook.infradead.org>
            <1231678799.25018.195.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1231692502_4078P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:45607 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751547AbZAKQs2 (ORCPT
	<RFC822;netdev@vger.kernel.org>); Sun, 11 Jan 2009 11:48:28 -0500
In-Reply-To: Your message of "Sun, 11 Jan 2009 12:59:59 GMT."
             <1231678799.25018.195.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1231692502_4078P
Content-Type: text/plain; charset=us-ascii

On Sun, 11 Jan 2009 12:59:59 GMT, David Woodhouse said:
> On Sun, 2009-01-11 at 12:25 +0000, David Woodhouse wrote:
> > I'll take a look and see if I can remedy that. Then we wouldn't _need_
> > the FIRMWARE_IN_KERNEL option.
> 
> How about this? If it fails to load the firmware from userspace during
> the initialisation, it'll try again later in tg3_open(). 
> 
> I _think_ that's fine, because we don't do anything else in the early
> initialisation which requires the firmware to be loaded.
> 
> So if you build with CONFIG_TIGON3=y, CONFIG_FIRMWARE_IN_KERNEL=n, you
> should see it fail to load the firmware at boot, but then it should load
> it successfully when you bring the device up.
> 
> Untested-but-otherwise-Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>

I'll see if I can give it a test drive sometime in the next 24 hours or so.

One unanswered question:  What do we expect the system to do if they have this
patch, TIGON3=y, FIRMWARE_IN_KERNEL=n, and configure a netconsole for boot
messages?  I'm *hoping* the answer is "the netconsole doesn't come up at boot,
but can be re-enabled via the /sys/kernel/config/netconsole interface after
you've done an 'ifconfig eth0 up' or similar, or do a 'modprobe netconsole'.

Those seem like reasonable semantics to me - anybody got a different opinion?


--==_Exmh_1231692502_4078P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJaiLWcC3lWbTT17ARAhbiAKD6akLybhJneWIx6nEeo6Vs+cqT4wCeJb9y
7Zfk95Gs5u5g8ypyydfrJ8c=
=mmwi
-----END PGP SIGNATURE-----

--==_Exmh_1231692502_4078P--
