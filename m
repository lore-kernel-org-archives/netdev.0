From: Valdis.Kletnieks@vt.edu
Subject: Re: [e1000_netpoll] BUG: sleeping function called from invalid context at kernel/irq/manage.c:110
Date: Thu, 28 Jul 2016 05:46:39 -0400
Message-ID: <18604.1469699199@turing-police.cc.vt.edu>
References: <20160726035003.GA15095@wfg-t540p.sh.intel.com> <1469524492.17736.3.camel@edumazet-glaptop3.roam.corp.google.com> <20160726093224.GA10339@wfg-t540p.sh.intel.com> <alpine.DEB.2.11.1607261149570.19896@nanos> <8578bb16-cd04-e8a5-c7f4-be061ede95b4@gmail.com>
 <alpine.DEB.2.11.1607280941450.19896@nanos>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1469699199_4839P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: nick <xerofoify@gmail.com>, Fengguang Wu <fengguang.wu@intel.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Satyam Sharma <satyam@infradead.org>,
	intel-wired-lan@lists.osuosl.org,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Ye Xiaolong <xiaolong.ye@intel.com>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from outbound.smtp.vt.edu ([198.82.183.121]:34954 "EHLO
	omr2.cc.vt.edu" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752782AbcG1Jrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2016 05:47:33 -0400
In-Reply-To: <alpine.DEB.2.11.1607280941450.19896@nanos>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1469699199_4839P
Content-Type: text/plain; charset=us-ascii

On Thu, 28 Jul 2016 09:45:12 +0200, Thomas Gleixner said:
> On Tue, 26 Jul 2016, nick wrote:
> > diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > index f42129d..e1830af 100644
> > --- a/drivers/net/ethernet/intel/e1000/e1000_main.c
> > +++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
> > @@ -3797,7 +3797,7 @@ static irqreturn_t e1000_intr(int irq, void *data)
> >  		hw->get_link_status = 1;
> >  		/* guard against interrupt when we're going down */
> >  		if (!test_bit(__E1000_DOWN, &adapter->flags))
> > -			schedule_delayed_work(&adapter->watchdog_task, 1);
> > +			mod_work(&adapter->watchdog_task, jiffies + 1);
>
> And that's not even funny anymore. Are you using a random generator to create
> these patches?

At some point, we need to decide if the occasional accidentally-correct
trivial patch from Nick is worth all the wasted maintainer time.


--==_Exmh_1469699199_4839P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBV5nUfwdmEQWDXROgAQJ4Vg//U+1L0Pj9u4cmFhgXZ5LiLTlYJlno1/Iv
1eegThUDVlS7RSZl6aTzYGcTj9/L8jcprXtIid1RgBMYCT1WZNwIjqx/6ruRbG1q
1B5SbqzfkkrYUEZazTMxScaGa9cTFFBuTM+UE9gpdD+2hmtXqPt1MK0Bl6TT7chL
0WIIx4QD/dYONfTndrlKdJ04154xFkZ8WRmeuJDrdgHHTCttiB8QfqxPiX4W7MZp
wYryUy7qB51XjoBBWo6TFdlP0rFI7ChwhPi0ljexn1LYWGyD7Ac0KpI7bk626OrI
yC6M/Ri9aL9ra+5pepmpd5Iux8GfJGGd53ViwbPhGuakBgSJoyOiv+yxwVFpw1wX
10kajEE70PVXD+wMMC3tcYXrrOZgMzzvVZbj+uEu/ZXWAJsJrmIF3Pcz0gidjL9g
VFdX8fIlyaVoL0jjlEvXoQmVD6FiZx6uWrFVenSz0NmrdlxPJmjE9Ye+Up++BTAz
o8bbmrv6P284dDJN0HH8CaFXfGmuo0hnnjFlBEZ4xVbiMKwLgG299g8ho2kGKQ4y
7sTHjKf5HIc7QFr3h0BVLkZYsfAyEhqijxcYMO1x2MkrpfBSTmx2ZYcJ6p5jeWoL
feULe0PRvuS1eCYtEk/BLt9hT5RICic57W0qVbDHJMBmsY4G6YMWjTPgicfWr3Jd
Tap/Gdii9Jw=
=NQE8
-----END PGP SIGNATURE-----

--==_Exmh_1469699199_4839P--
