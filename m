From: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Sun, 27 May 2007 23:46:16 +0200
Message-ID: <200705272346.19760.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <200705272236.42628.maxi@daemonizer.de> <200705272246.16960.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart13571105.gMBMrhRZdQ";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Stephen Hemminger <shemminger-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-f8uhVLnGfZaxAyOMLChx1axOck334EZe@public.gmane.org>,
	Jeff Garzik <jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>,
	Gary Zambrano <zambrano-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
To: Michael Buesch <mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200705272246.16960.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart13571105.gMBMrhRZdQ
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 27 May 2007, Michael Buesch wrote:
> On Sunday 27 May 2007 22:36:39 Maximilian Engelhardt wrote:
> > When I ran 2.6.21.1 or 2.6.22-rc3 without any debugging tools just in
> > normal use I didn't notice any problems. It did work fine as I would
> > expect it. I think the wget and ping tests here are as they should be.
> >
> > With 2.6.22-rc2-mm1 I noticed that connections seem to be slower. The
> > ping test does confirm this, because here response times are very high.
> > As far as I can remember the wget download rate was a bit slower than
> > 2.6.21.1 or 2.6.22-rc3 till it stalled.
> > I would expect it to be someting like the other two kernels. The two
> > problems I see are the high ping times and the fact that the card stopp=
ed
> > working.
> >
> > I don't know why the iperf results are so different from my personal
> > experience. I guess the fact that I get so bad results with 2.6.21.1 and
> > 2.6.22-rc3 is that iperf does something that causes the system to be
> > extremely slow and thus degrading performance. This could be a bug
> > somewhere in the b44 driver of 2.6.21.1 and 2.6.22-RC3 that has
> > unintended been fixed by the ssb switch, but that's only a roughly gues=
s.
>
> Ok. I guess (Yes I do :D) that there is an IRQ storm or something like
> that, because you say that your system is becoming very slow and
> unresponsive. It sounds like an IRQ is not ACKed correctly and so keeps
> triggering and stalling the system. I'll take a look at a few diffs...
> Do you see significant differences in the "hi" and/or "si" times in top?
> Do you see a significant difference in the /proc/interrupts count. For
> example that the kernel that works worse generates 10 times the IRQ count
> for the same amount of data.

ok, here are the results:

Using 2.6.22-rc3 I get lot's of hi during TX and lots of hi and si during R=
X.
Using 2.6.22-rc3-mm1 hi and si are significantly lower.
It's difficult to give absolute numbers, because top refreshes very slow, b=
ut=20
with 2.6.22-rc3 hi is about 30% during TX and RX and si is 0% during TX and=
=20
50% during RX. With Using 2.6.22-rc3-mm1 hi is 0% during TX and 0.3% during=
=20
RX and si is 10% during TX and 0% during RX.

When I do the same test on both kernels I get about 10 times (yes, it's rea=
lly=20
about ten times like in your example) more interrupts with 2.6.22-rc3 than=
=20
with 2.6.22-rc3-mm1.

An additional thing I noticed it that it's not the BCM4401 card that stops=
=20
working but my e100 card. If I take the e100 card down and up again the=20
connection is working again, so the BCM4401 doesn't have a "stops working"=
=20
bug for me.

Maxi

--nextPart13571105.gMBMrhRZdQ
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGWfwrOimwv528XGERAiRQAKCppkNe/vGsseEZc7dhV9Bi37kVFwCgi/hH
JBquJ1vl8K3Nlo24tWO/5Pw=
=WHFe
-----END PGP SIGNATURE-----

--nextPart13571105.gMBMrhRZdQ--
