From: Maximilian Engelhardt <maxi-OwNUvPV92VfddJNmlsFzeA@public.gmane.org>
Subject: Re: b44: regression in 2.6.22 (resend)
Date: Mon, 28 May 2007 00:15:59 +0200
Message-ID: <200705280016.02776.maxi@daemonizer.de>
References: <20070525172431.60affaca@freepuppy> <200705272125.25506.maxi@daemonizer.de> <200705272313.33129.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart1256911.S444X9Ocex";
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
In-Reply-To: <200705272313.33129.mb-fseUSCV1ubazQB+pC5nmwQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

--nextPart1256911.S444X9Ocex
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 27 May 2007, Michael Buesch wrote:
> On Sunday 27 May 2007 21:25:17 Maximilian Engelhardt wrote:
> > 2.6.21.1:
> > [  5] local 192.168.1.2 port 58414 connected with 192.168.1.1 port 5001
> > [  5]  0.0-60.6 sec  1.13 MBytes    157 Kbits/sec
> > [  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 57837
> > [  4]  0.0-63.1 sec  2.82 MBytes    375 Kbits/sec
> >
> > 2.6.22-rc3:
> > [  5] local 192.168.1.2 port 46557 connected with 192.168.1.1 port 5001
> > [  5]  0.0-60.4 sec  58.9 MBytes  8.18 Mbits/sec
> > [  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 51633
> > [  4]  0.0-63.1 sec  7.27 MBytes    967 Kbits/sec
>
> This is the diff between these two kernels.
> I'm not sure why you see a much better TX throughput here.
>
> Can you re-check to make sure it's not just some test-jitter?
>
2.6.21.1:

[  5] local 192.168.1.2 port 54423 connected with 192.168.1.1 port 5001
[  5]  0.0-60.3 sec  3.06 MBytes    426 Kbits/sec
[  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 41053
[  4]  0.0-163.0 sec    130 MBytes  6.67 Mbits/sec


2.6.22-rc3:

[  5] local 192.168.1.2 port 46002 connected with 192.168.1.1 port 5001
[  5]  0.0-61.5 sec  84.0 MBytes  11.5 Mbits/sec
[  4] local 192.168.1.2 port 5001 connected with 192.168.1.1 port 44379
[  4]  0.0-93.8 sec  30.6 MBytes  2.74 Mbits/sec

=46or TX the iperf server reports the same values as the client (all values=
 are=20
from the client) but for RX they are differen:

2.6.21.1: (iperf server log):

[  5] local 192.168.1.1 port 5001 connected with 192.168.1.2 port 54423
[  5]  0.0-60.5 sec  3.06 MBytes    425 Kbits/sec
[  5] local 192.168.1.1 port 41053 connected with 192.168.1.2 port 5001
[  5]  0.0-63.1 sec    130 MBytes  17.2 Mbits/sec


2.6.22-rc3 (iperf server log):

[  4] local 192.168.1.1 port 5001 connected with 192.168.1.2 port 46002
[  4]  0.0-61.6 sec  84.0 MBytes  11.5 Mbits/sec
[  4] local 192.168.1.1 port 44379 connected with 192.168.1.2 port 5001
[  4]  0.0-63.3 sec  30.6 MBytes  4.06 Mbits/sec

I have no idea how iperf internally works and what can cause such different=
=20
results here.

>
> --- linux-2.6.21.1/drivers/net/b44.c    2007-05-27 22:58:01.000000000 +02=
00
> +++ linux-2.6.22-rc3/drivers/net/b44.c  2007-05-27 23:01:44.000000000 +02=
00
> @@ -825,12 +825,11 @@
>                         if (copy_skb =3D=3D NULL)
>                                 goto drop_it_no_recycle;
>
> -                       copy_skb->dev =3D bp->dev;
>                         skb_reserve(copy_skb, 2);
>                         skb_put(copy_skb, len);
>                         /* DMA sync done above, copy just the actual pack=
et
> */ -                       memcpy(copy_skb->data, skb->data+bp->rx_offset,
> len); -
> +                       skb_copy_from_linear_data_offset(skb,
> bp->rx_offset, +                                                      =20
> copy_skb->data, len); skb =3D copy_skb;
>                 }
>                 skb->ip_summed =3D CHECKSUM_NONE;
> @@ -1007,7 +1006,8 @@
>                         goto err_out;
>                 }
>
> -               memcpy(skb_put(bounce_skb, len), skb->data, skb->len);
> +               skb_copy_from_linear_data(skb, skb_put(bounce_skb, len),
> +                                         skb->len);
>                 dev_kfree_skb_any(skb);
>                 skb =3D bounce_skb;
>         }



--nextPart1256911.S444X9Ocex
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQBGWgMiOimwv528XGERAjsHAKDR1KjfwQMgZRyMFZcGuwbHbaxJcQCgtMPZ
RX0ulE+gPKEVDo3hgfqfA6U=
=uMCj
-----END PGP SIGNATURE-----

--nextPart1256911.S444X9Ocex--
