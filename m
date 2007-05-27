From: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Sun, 27 May 2007 22:36:39 +0200
Message-ID: <200705272236.42628.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <200705272125.25506.maxi@daemonizer.de> <200705272145.00796.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1631912.GuXSa6SRHs";
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
In-Reply-To: <200705272145.00796.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1631912.GuXSa6SRHs
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 27 May 2007, Michael Buesch wrote:
> On Sunday 27 May 2007 21:25:17 Maximilian Engelhardt wrote:
> > 2.6.22-rc3:
> >
> > [  5] local 192.168.1.2 port 46557 connected with 192.168.1.1 port 5001
> > [  5]  0.0-60.4 sec  58.9 MBytes  8.18 Mbits/sec
> > [  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 51633
> > [  4]  0.0-63.1 sec  7.27 MBytes    967 Kbits/sec
>
> Why do we have two different measurements here? Is one TX and one RX?
> Which one?

Yes, the first is TX (BCM4401 --> e100) and the second is RX. Both are tcp=
=20
connections. I think iperf does display the ip addresses wrong in the secon=
d=20
connection, but that's another issue.

>
> > koala:~# ping -c10 192.168.1.1
> > PING 192.168.1.1 (192.168.1.1) 56(84) bytes of data.
> > 64 bytes from 192.168.1.1: icmp_seq=3D1 ttl=3D64 time=3D0.243 ms
> > 64 bytes from 192.168.1.1: icmp_seq=3D2 ttl=3D64 time=3D0.234 ms
> > 64 bytes from 192.168.1.1: icmp_seq=3D3 ttl=3D64 time=3D0.238 ms
> > 64 bytes from 192.168.1.1: icmp_seq=3D4 ttl=3D64 time=3D0.235 ms
> > 64 bytes from 192.168.1.1: icmp_seq=3D5 ttl=3D64 time=3D0.230 ms
> > 64 bytes from 192.168.1.1: icmp_seq=3D6 ttl=3D64 time=3D0.317 ms
> > 64 bytes from 192.168.1.1: icmp_seq=3D7 ttl=3D64 time=3D0.232 ms
> > 64 bytes from 192.168.1.1: icmp_seq=3D8 ttl=3D64 time=3D0.232 ms
> > 64 bytes from 192.168.1.1: icmp_seq=3D9 ttl=3D64 time=3D0.228 ms
> > 64 bytes from 192.168.1.1: icmp_seq=3D10 ttl=3D64 time=3D0.238 ms
> >
> > --- 192.168.1.1 ping statistics ---
> > 10 packets transmitted, 10 received, 0% packet loss, time 8997ms
> > rtt min/avg/max/mdev =3D 0.228/0.242/0.317/0.031 ms
> >
> > System responsiveness was the same as with 2.6.21.1.
> >
> > wget got 11.23M/s, again same as 2.6.21.1.
> >
> >
> > 2.6.22-rc2-mm1:
> >
> > [  5] local 192.168.1.2 port 42198 connected with 192.168.1.1 port 5001
> > [  5]  0.0-60.1 sec    402 MBytes  56.1 Mbits/sec
> > [  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 48598
> > [  4]  0.0-63.0 sec    177 MBytes  23.6 Mbits/sec
>
> So with -mm (with ssb) you actually get better performace
> then with plain 2.6.22-rc3?
>
> Can you elaborate a bit more about what you get an what you expect
> on which kernel?

When I ran 2.6.21.1 or 2.6.22-rc3 without any debugging tools just in norma=
l=20
use I didn't notice any problems. It did work fine as I would expect it.
I think the wget and ping tests here are as they should be.

With 2.6.22-rc2-mm1 I noticed that connections seem to be slower. The ping=
=20
test does confirm this, because here response times are very high. As far a=
s=20
I can remember the wget download rate was a bit slower than 2.6.21.1 or=20
2.6.22-rc3 till it stalled.
I would expect it to be someting like the other two kernels. The two proble=
ms=20
I see are the high ping times and the fact that the card stopped working.

I don't know why the iperf results are so different from my personal=20
experience. I guess the fact that I get so bad results with 2.6.21.1 and=20
2.6.22-rc3 is that iperf does something that causes the system to be=20
extremely slow and thus degrading performance. This could be a bug somewher=
e=20
in the b44 driver of 2.6.21.1 and 2.6.22-RC3 that has unintended been fixed=
=20
by the ssb switch, but that's only a roughly guess.

Maxi

--nextPart1631912.GuXSa6SRHs
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGWevaOimwv528XGERAjKxAKDvRo+nKsr890vta1lDS/kdZOMYOQCfeXx7
M91ByEdu223aD5X7CR/K06w=
=8OR6
-----END PGP SIGNATURE-----

--nextPart1631912.GuXSa6SRHs--
