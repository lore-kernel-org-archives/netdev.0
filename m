From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.28-git8: tg3 doesn't work due to firmware not loading (-git7 is ok)
Date: Mon, 12 Jan 2009 23:46:28 -0500
Message-ID: <5444.1231821988@turing-police.cc.vt.edu>
References: <5a4c581d0901090930j5d4760b0x730b5609fa2b5614@mail.gmail.com> <20090109.140422.60087297.davem@davemloft.net> <43805.1231672258@turing-police.cc.vt.edu> <20090111.040842.86784676.davem@davemloft.net> <1231676698.25018.147.camel@macbook.infradead.org> <1231678799.25018.195.camel@macbook.infradead.org> <4407.1231719036@turing-police.cc.vt.edu>
            <1231748039.25018.1277.camel@macbook.infradead.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1231821988_3103P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, alessandro.suardi@gmail.com,
	jaswinderlinux@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from turing-police.cc.vt.edu ([128.173.14.107]:54336 "EHLO
	turing-police.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754534AbZAMEqg (ORCPT
	<RFC822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 23:46:36 -0500
In-Reply-To: Your message of "Mon, 12 Jan 2009 08:13:59 GMT."
             <1231748039.25018.1277.camel@macbook.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--==_Exmh_1231821988_3103P
Content-Type: text/plain; charset=us-ascii

On Mon, 12 Jan 2009 08:13:59 GMT, David Woodhouse said:
> On Sun, 2009-01-11 at 19:10 -0500, Valdis.Kletnieks@vt.edu wrote:
> > So it looks like the patch is failing to finish initialization of the card.
> > Damned if *I* can see what's breaking it, the conversion to use a helper
> > function tg3_request_firmware seems sane enough....
> 
> Ahem...
> 
> --- drivers/net/tg3.c.stupiddwmw2	2009-01-12 08:13:05.000000000 +0000
> +++ drivers/net/tg3.c	2009-01-12 08:13:09.000000000 +0000
> @@ -13151,7 +13151,7 @@ static int __devinit tg3_init_one(struct

OK, tested on my laptop.  Results:

CONFIG_TIGON3=y CONFIG_PREVENT_FIRMWARE_BUILD=y works - the firmware gets
loaded during early system boot and all is as expected.

CONFIG_TIGON3=y CONFIG_FIRMWARE_IN_KERNEL=n wedges up - Booted with
'ignore_loglevel initcall_debug', and the last thing we get is:

tg3 0000:09:00.0: firmware: requesting tigon/tg3_tso.bin

At which point we hang because request_firmware apparently never returns.
It's wedged up *really* good at that point - I can't even use
alt-sysrq-anything.



--==_Exmh_1231821988_3103P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.9 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFJbBykcC3lWbTT17ARAtFeAJ474Z8GwNX4FR+uFZT2tl320F6pdgCfe2us
+SbUwIsj5kdaBIUMaYE2HVE=
=QO5q
-----END PGP SIGNATURE-----

--==_Exmh_1231821988_3103P--
