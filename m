From: "Wesley W. Terpstra" <terpstra@gkec.tu-darmstadt.de>
Subject: Re: Broken? 2.6.6 + IP_ADD_SOURCE_MEMBERSHIP + SO_REUSEADDR
Date: Fri, 4 Jun 2004 23:29:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040604212916.GA6683@muffin>
References: <20040604155423.GA5656@muffin> <20040605.015544.102223977.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com, davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20040605.015544.102223977.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 05, 2004 at 01:55:44AM +0900, YOSHIFUJI Hideaki / =E5=90=89=E8=
=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20040604155423.GA5656@muffin> (at Fri, 4 Jun 2004 17:54:23 =
+0200), "Wesley W. Terpstra" <terpstra@gkec.tu-darmstadt.de> says:
> > If I launch the same program twice with different senders, the first =
program
> > ceases to receive multicast packets. (Neither from its own sender, no=
r the
> > second program's sender) The second program receives packets from its
> > designated sender only (as expected).
> >
> > If both programs specify the same sender, then both programs receive =
the
> > message (as expected).
>=20
> Thanks for the report.
> The following patch should fix the issue. Please try.
> Thanks again.
>=20
> =3D=3D=3D=3D=3D net/ipv4/udp.c 1.60 vs edited =3D=3D=3D=3D=3D
> --- 1.60/net/ipv4/udp.c	2004-05-31 03:57:26 +09:00
> +++ edited/net/ipv4/udp.c	2004-06-05 01:47:07 +09:00
> @@ -294,7 +294,7 @@
>  		    ipv6_only_sock(s)					||
>  		    (s->sk_bound_dev_if && s->sk_bound_dev_if !=3D dif))
>  			continue;
> -		if (!ip_mc_sf_allow(sk, loc_addr, rmt_addr, dif))
> +		if (!ip_mc_sf_allow(s, loc_addr, rmt_addr, dif))
>  			continue;
>  		goto found;
>    	}

That works.
I have confirmed that multiple senders for multiple processes is fixed.

I am amazed you fixed it so fast!
Will this make it into 2.6.7?

--=20
Wesley W. Terpstra
