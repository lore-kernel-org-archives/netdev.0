From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: [PATCH] OpenBSD Networking-related randomization port
Date: Fri, 28 Jan 2005 21:47:45 +0100
Message-ID: <1106945266.7776.41.camel@laptopd505.fenrus.org>
References: <1106932637.3778.92.camel@localhost.localdomain>
	 <20050128100229.5c0e4ea1@dxpl.pdx.osdl.net>
	 <1106937110.3864.5.camel@localhost.localdomain>
	 <20050128105217.1dc5ef42@dxpl.pdx.osdl.net>
	 <1106944492.3864.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Chris Wright <chrisw@osdl.org>, netdev@oss.sgi.com,
        Hank Leininger <hlein@progressive-comp.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Lorenzo =?ISO-8859-1?Q?Hern=E1ndez_?= =?ISO-8859-1?Q?Garc=EDa-Hierro?= <lorenzo@gnu.org>
In-Reply-To: <1106944492.3864.30.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2005-01-28 at 21:34 +0100, Lorenzo Hern=C3=A1ndez Garc=C3=ADa-Hie=
rro
wrote:
> Hi,
>=20
> Attached the new patch following Arjan's recommendations.
> I'm sorry about not making it "inlined", but my mail agent messes up th=
e
> diffs if I do so.
> Still waiting for the OSDL STP tests results, they will take a while to
> finish.
>=20
> Cheers,

lots better already! Some more comments (now that the patch got a lot
easier to read :)

 static inline __u32 tcp_v4_init_sequence(struct sock *sk, struct
sk_buff *skb)
 {
-       return secure_tcp_sequence_number(skb->nh.iph->daddr,
-                                         skb->nh.iph->saddr,
-                                         skb->h.th->dest,
-                                         skb->h.th->source);
+
+               return ip_randomisn();
 }

is there a reason for the weird indentation?

+       if (!tp->write_seq) {
+                       tp->write_seq =3D ip_randomisn();
+       }

spare { } pare that's not needed, also looks like one tab too many


as for obsd_get_random_long().. would it be possible to use the
get_random_int() function from the patches I posted the other day? They
use the existing random.c infrastructure instead of making a copy...

I still don't understand why you need a obsd_rand.c and can't use the
normal random.c


 =20
 static inline u32 xprt_alloc_xid(struct rpc_xprt *xprt)
 {
-       return xprt->xid++;
+       /* Return randomized xprt->xid instead of prt->xid++ */
+       return (u32) obsd_get_random_long();
+
 }
=20

that cast looks quite redundant...
