From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next] ipv6: unify conntrack reassembly expire
 code with standard one
Date: Mon, 20 Aug 2012 17:06:39 +0800
Message-ID: <1345453599.22373.9.camel@cr0>
References: <1345190565-21689-1-git-send-email-amwang@redhat.com>
	 <1826853.rak2U42CMU@alaris>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Shan Wei <shanwei@cn.fujitsu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org
To: Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1826853.rak2U42CMU@alaris>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Michal!

On Fri, 2012-08-17 at 19:05 +0200, Michal Kube=C4=8Dek wrote:
> On Friday 17 of August 2012 16:02EN, Cong Wang wrote:
> > Two years ago, Shan Wei tried to fix this:
> > http://patchwork.ozlabs.org/patch/43905/
> >=20
> ...
> >
> > As Herbert suggested, we could actually use the standard IPv6
> > reassembly code which follows RFC2460.
>=20
> I tested the patch and I ran into a problem in this place in=20
> ip6_expire_frag_queue():
>=20
> >  	net =3D container_of(fq->q.net, struct net, ipv6.frags);
>=20
> For frag queues coming from IPv6 conntrack, fq->q.net points to=20
> nf_init_frags which is not embedded into struct net so that the=20
> following device lookup leads to reading from an invalid address.
> The same problem has been discussed on the page linked above.
>=20
> I didn't test with current net-next source but as far as I can tell,=20
> this hasn't changed. Did I miss something?
>=20

No, you don't miss anything. I missed that piece of code, you are right
that nf_init_frags is not actually embedded, so that container_of()
doesn't work. I think we probably can save the struct net pointer in
struct netns_frags during inet_frags_init_net(), so that container_of()
can be eliminated.=20

Thanks for testing! I tried to test it too, but seems I can't trigger a
defragment. Any hints?

Thanks!

--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
