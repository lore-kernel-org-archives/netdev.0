From: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Subject: Re: iperf: performance regression (was b44 driver problem?)
Date: Mon, 4 Jun 2007 22:52:36 +0200
Message-ID: <200706042252.40025.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <200706042148.02450.maxi@daemonizer.de> <20070604130225.08e45b72@freepuppy>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1781395.qdN5C00hYe";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>, Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Ulrich Drepper <drepper-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	linux-kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20070604130225.08e45b72@freepuppy>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1781395.qdN5C00hYe
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Monday 04 June 2007, Stephen Hemminger wrote:
> On Mon, 4 Jun 2007 21:47:59 +0200
>
> Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org> wrote:
> > On Monday 04 June 2007, Ingo Molnar wrote:
> > > * Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> wrote:
> > > > Yes, the following patch makes iperf work better than ever. But are
> > > > other broken applications going to have same problem. Sounds like t=
he
> > > > old "who runs first" fork() problems.
> > >
> > > this is the first such app and really, and even for this app: i've be=
en
> > > frequently running iperf on -rt kernels for _years_ and never noticed
> > > how buggy its 'locking' code was, and that it would under some
> > > circumstances use up the whole CPU on high-res timers.
> >
> > I must admit I don't know much about that topic, but there is one thing=
 I
> > don't understand. Why is iperf (even if it's buggy) able to use up the
> > whole cpu? I didn't run it as root but as my normal user so it should
> > have limited rights. Shouldn't the linux scheduler distribute cpu time
> > among all running processes?
>
> In this case, there are two threads. One is receiving data and the other
> is spinning checking on progress. If the spinning thread doesn't yield,
> it will end up using it's whole quantum (10ms at 100hz), before the
> scheduler lets the receiver run again. If the receiving thread doesn't
> get to run then on a UP the performance stinks.
>
Ok, let's see if I got this right:
If there are other processes that want cpu time they will get it after the=
=20
quantum for the iperf thread is used up. So cpu time will be distributed=20
among other processes, but it takes some time until they get it and this=20
increases latency.

> The problem only showed up laptop because most of my other systems are
> SMP (or fake SMP/HT), and usually set HZ to 1000 not 100.

Hm, on my laptop (Pentium M) I have configured CONFIG_HZ_300 and CONFIG_NO_=
HZ.
On my desktop PC (Athlon 2000+, also UP) I also have CONFIG_HZ_300 and=20
CONFIG_NO_HZ but didn't notice the problem.

Maxi

--nextPart1781395.qdN5C00hYe
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGZHuXOimwv528XGERArEsAKDgMGu94r/glT+KaM30/ryWhocb3QCgsxPc
ENx/hbwtIaDWZCeEcpHEjRk=
=Yhkf
-----END PGP SIGNATURE-----

--nextPart1781395.qdN5C00hYe--
