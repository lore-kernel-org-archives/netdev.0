From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB
 originated TCP streams
Date: Mon, 06 Feb 2012 16:21:46 +0100
Message-ID: <1328541706.2220.50.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com>
	  <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com>
	  <alpine.LRH.2.00.1202022352560.30300@ogerlitz.voltaire.com>
	  <1828884A29C6694DAF28B7E6B8A823733349A5D2@ORSMSX101.amr.corp.intel.com>
	 <1328259640.2480.43.camel@edumazet-laptop>
	 <1828884A29C6694DAF28B7E6B8A823733349A6C9@ORSMSX101.amr.corp.intel.com>
	 <4F2FEC36.6090800@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F2FEC36.6090800-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 17:05 +0200, Or Gerlitz a =C3=A9cr=
it :
> On 2/3/2012 10:24 PM, Hefty, Sean wrote:
> >> Hmm... a tcpdump would help to understand what is going on (for ex=
ample if GRO kicks in)
> >
> > I should stop trying to apply patches so late.  I must have done so=
mething wrong with my quick test.  Re-applying the patch on 3.2, the ip=
oib UD performance looks okay to me with Eric's patch.  Sorry about the=
 flub.
> >
>=20
> Sean, same here, with both 3.2 and 3.3-rc1 I see with tcpdump that no=
=20
> GRO aggregation is done in the receiving side, when applying the patc=
h I=20
> sent (Eric's patch enhanced to change ipoib code such that it sets=20
> gro_mac_header_lento the ipoib header len), I can see GRO aggregation=
=20
> and the performance goes well up. So how do we go from here? Herbert,=
=20
> Roland, are you okay with the patch?
>=20
> Eric, if this we're going on that patch, could you please add=20
> Reported-by: Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org> to the change-log=
=2E

Sure, I suggest two patches then.

One from me (the one I sent earlier), introducing the core
infrastructure, and one from you adding the "dev->gro_mac_header_len  =3D
IPOIB_ENCAP_LEN;" in drivers/infiniband/ulp/ipoib/ipoib_main.c

If you agree, I'll resend my part with official submission, and you'll
send your patch after ?



--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
