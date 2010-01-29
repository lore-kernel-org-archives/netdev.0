From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: reproducible crash KVM+nf_conntrack all recent 2.6
 kernels
Date: Fri, 29 Jan 2010 10:10:32 +0100
Message-ID: <1264756232.3184.10.camel@edumazet-laptop>
References: <1264657559.2793.103.camel@tonnant>
	 <1264658364.2793.105.camel@tonnant>  <4B6180D1.6050609@trash.net>
	 <1264720891.2793.205.camel@tonnant>  <1264727492.2793.207.camel@tonnant>
	 <1264754565.2793.405.camel@tonnant>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: Jon Masters <jonathan@jonmasters.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1264754565.2793.405.camel@tonnant>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le vendredi 29 janvier 2010 =C3=A0 03:42 -0500, Jon Masters a =C3=A9cri=
t :
> Hi,
>=20
> So I did some poking (still trying to figure out netfilter a little
> internally) and looked over the handling of connection tracking. The
> oops reports I have been getting generally lie in __nf_conntrack_find=
,
> specifically within a hlist iterator that looks up the information fo=
r
> the current connection in a per-net namespace hashtable (under RCU, i=
t's
> been locked already by the time we get in here). Here's the piece:
>=20
>         hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash],
> hnnode) {
>                 if (nf_ct_tuple_equal(tuple, &h->tuple)) {
>                         NF_CT_STAT_INC(net, found);
>                         local_bh_enable();
>                         return h;
>                 }
>                 NF_CT_STAT_INC(net, searched);
>         }
>=20
> Instrumenting the kernel at the moment and then setting up more of a
> debugging environment to poke at what goes wrong here. Perhaps there'=
s
> some broken RCU assumption - I just spent the last few hours reading
> over netfilter source and Paul's RCU docs again to brush up.
>=20
> Perhaps you netdev folks can let me know if there's a handy netfilter
> debugging guide somewhere.
>=20
> Jon.
>=20
>=20

Jon, do you have multiple network namespace active on your machine, whe=
n
crash occurs ?



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
