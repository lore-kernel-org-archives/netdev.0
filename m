From: SZALAY Attila <sasa@balabit.hu>
Subject: Re: Problem with __check_and_rekey
Date: Tue, 12 Aug 2003 16:05:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030812140516.GA27237@mochrul.balabit>
References: <20030812132050.GA27178@mochrul.balabit> <20030812.225527.35784879.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: sasa@balabit.hu, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20030812.225527.35784879.yoshfuji@linux-ipv6.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi ALl!


On 2003 Aug 12, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> In article <20030812132050.GA27178@mochrul.balabit> (at Tue, 12 Aug 200=
3 15:20:50 +0200), SZALAY Attila <sasa@balabit.hu> says:
>=20
> But anyway, I can't find these lines in linux-2.4.21 (or even in 2.6.x).
> Are you sure you're working on the vanilla kernel?

Sorry, no.

The patch in vanilla kernel:

--- tcp_ipv4.c~ Tue Aug 12 16:01:31 2003
+++ tcp_ipv4.c  Tue Aug 12 16:03:35 2003
@@ -843,9 +843,12 @@
        if (err)
                goto failure;
=20
-       if (!tp->write_seq)
+       if (!tp->write_seq) {
+               local_bh_disable();
                tp->write_seq =3D secure_tcp_sequence_number(sk->saddr, s=
k->daddr,
                                                           sk->sport, usi=
n->sin_port);
+               local_bh_enable();
+       }
=20
        sk->protinfo.af_inet.id =3D tp->write_seq^jiffies;



--=20
Szalay Attila                     BalaBit IT Biztons=E1gtechnikai Kft.
tel:(36-1)-371-05-40              1116 Bp. Csurgoi ut 20/b
fax:(36-1)-208-08-75              http://www.balabit.hu/
