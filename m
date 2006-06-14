From: Harald Welte <laforge@gnumonks.org>
Subject: Re: driver for pptp
Date: Wed, 14 Jun 2006 15:18:01 +0200
Message-ID: <20060614131801.GT11863@sunbeam.de.gnumonks.org>
References: <E1FmQDD-0005kY-00.xeb-mail-ru@f51.mail.ru>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="5A+fdviE5qijz5W3"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ganesha.gnumonks.org ([213.95.27.120]:26036 "EHLO
	ganesha.gnumonks.org") by vger.kernel.org with ESMTP
	id S964911AbWFNNSF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jun 2006 09:18:05 -0400
To: xeb@mail.ru
Content-Disposition: inline
In-Reply-To: <E1FmQDD-0005kY-00.xeb-mail-ru@f51.mail.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--5A+fdviE5qijz5W3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Sat, Jun 03, 2006 at 11:06:19AM +0400, xeb@mail.ru wrote:
> I have developed the driver for Point-to-Point Tunneling Protocol (PPTP).

great news.  something that I always thought of a nice-to-have.=20

> I have published the project on http://accel-pptp.sourceforge.net/

Please don't expect Linux Kernel networking developers to actually go to
sourceforge download and extract code that you want to have
reviewed/submitted.

Please read Documentation/SubmittingPatches (and CodingStyle) and submit
your kernel patch to netdev.

> Hope this driver will go to a kernel tree and will make linux more produc=
tive.

not without you pushing it actively and getting through review cycles
(which I hope you will!).

Some initial comments:

1) why wasn't it possible to use the PPPoX infrastructure of the kernel
   which is already being used by PPPoE ?  Or at least model it somehow
   similar to the existing PPPoE/PPPoX infrastructure?

2) why are you using a timer for asynchronous processing of GRE frames?
   First of all, why does it have to happen asynchronously at all?
   Secondly, why using a timer when there's nothing time related (or do
   I miss something)?  If deferred, out-of-context execution is
   required, there are other primitives such as tasklets.

3) you conflict with the ip_gre.c genric GRE encapsulation driver.  this
   is because both want to reigster a proto handler for GRE.  Ideally,
   there needs to be another demultiplex between the GRE protocl and its
   users.  The code registered for GRE would look at the packet and
   determine whether e.g. it is a PPTP GRE packet and then pass it on to
   the pptp module.

4) your code doesn't look nonlinear skb clean

5) why did you chose to implement  /dev/pptp rather than a socket family
   like the existing pppox/pppoe code?

6) lots of codingstyle issues

--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
We all know Linux is great...it does infinite loops in 5 seconds. -- Linus

--5A+fdviE5qijz5W3
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.3 (GNU/Linux)

iD8DBQFEkAyJXaXGVTD0i/8RAnSKAJ9DvofhPmRffBhr1fmL5sijZKuYgwCghcYl
1kB0MugbP92zlXsKRhp5ZF0=
=ik1s
-----END PGP SIGNATURE-----

--5A+fdviE5qijz5W3--
