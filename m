From: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Tue, 29 May 2007 19:23:22 +0200
Message-ID: <200705291923.26438.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <200705282255.56490.maxi@daemonizer.de> <1180447123.17146.4.camel@dhcp-10-12-136-115.broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart4060505.77Nsh39oUo";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "Thomas Gleixner" <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"Michael Buesch" <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>,
	"linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Stephen Hemminger" <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	"Arnaldo Carvalho de Melo" <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	"Jeff Garzik" <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"Andrew Morton" <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: "Gary Zambrano" <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1180447123.17146.4.camel-opBMJL+S1+nCw/J+WP9nZ0NK2P1VvzQgpWgKQ6/u3Fg@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart4060505.77Nsh39oUo
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Tuesday 29 May 2007, Gary Zambrano wrote:
> On Mon, 2007-05-28 at 13:55 -0700, Maximilian Engelhardt wrote:
> > On Monday 28 May 2007, Thomas Gleixner wrote:
> > > On Mon, 2007-05-28 at 19:44 +0200, Maximilian Engelhardt wrote:
> > > > > Can you please keep CONFIG_HIGH_RES_TIMERS and CONFIG_NOHZ and try
> > > > > the following combinations on the kernel command line:
> > > > >
> > > > > 1) highres=3Doff nohz=3Doff (should be the same as your working c=
onfig)
> > > > > 2) highres=3Doff
> > > > > 3) nohz=3Doff
> > > >
> > > > I tested this with my 2.6.22-rc3 kernel, here are the results:
> > > >
> > > > without any special boot parameters: problem does appear
> > > > highres=3Doff nohz=3Doff: problem does not appear
> > > > highres=3Doff: problem does not appear
> > > > nohz=3Doff: problem does appear
> > >
> > > Is there any other strange behavior of the high res enabled kernel th=
an
> > > the b44 problem ?
> >
> > I didn't notice anything.
> >
> > > > I additionally built my 2.6.22-rc2-mm1 kernel without High Resoluti=
on
> > > > Timer, but the high ping problem is still there.
> > >
> > > Hmm, that's mysterious. Wild guess is that highres exposes the hidden
> > > "feature" in a different way than rc2-mm1 does.
> >
> > I think the bug in 2.6.21/22-rc3 is a different one that the one in
> > 2.6.22-rc2-mm1, but that's also only a wild guess :)
> >
> > I'll explain this a bit:
> > In 2.6.21/22-rc3 is the same b44 driver that has been in the stock
> > kernels for some time. With this driver and High Resolution Timer turned
> > on I get problems using iperf. The problems are that the systems becomes
> > really slow and unresponsive.  Michael Buesch thought this could be an
> > IRQ storm which sounds logical to me. This bug did never happen to me
> > before I startet the iperf test.
>
> Can you please check to see if you notice anything out of the ordinary
> using netperf in place of iperf in your high res timer on/off testbed?

ok, here are the results, I also had a look at the cpu kernel usage.
'good' means that the kernel responsiveness during the test was as I would=
=20
expect it and I didn't notice any problems.

highres enabled:

netperf: 80%sy 15%si (good)
iperf: not really messureable (bad, problem described above)

highres disabled:

netperf: 80%sy 15%si (good)
iperf:  5%sy 30%hi 15%si (good)


for test tests I did run the following commands:
netperf -l 60 192.168.1.1
iperf -c 192.168.1.1 -r -t 60

I also tried to run iperf without any additional arguments (iperf -c=20
192.168.1.1) on the problematic kernel but the result is the same as the=20
command I wrote above.

Maxi

--nextPart4060505.77Nsh39oUo
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGXGGOOimwv528XGERAsw/AJ4m3Q0hahe28KIFZwtueQqHyE0kagCePF//
6jyHP5GW0uXcLTRFci3rXoU=
=8pPH
-----END PGP SIGNATURE-----

--nextPart4060505.77Nsh39oUo--
