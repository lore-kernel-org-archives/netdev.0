From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/4] ipv6: add a new namespace for nf_conntrack_reasm
Date: Tue, 18 Sep 2012 09:37:56 +0200
Message-ID: <20120918073756.GA18206@1984>
References: <1347942582-23962-1-git-send-email-amwang@redhat.com>
 <1347942582-23962-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	Michal =?utf-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1347942582-23962-2-git-send-email-amwang@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 18, 2012 at 12:29:39PM +0800, Cong Wang wrote:
> As pointed by Michal, it is necessary to add a new
> namespace for nf_conntrack_reasm code, this prepares
> for the second patch.

This looks good to me, but there are some comestical changes I have to
request.

> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> Cc: Michal Kube=C4=8Dek <mkubecek@suse.cz>
> Cc: David Miller <davem@davemloft.net>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Pablo Neira Ayuso <pablo@netfilter.org>
> Cc: netfilter-devel@vger.kernel.org
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---
>  include/net/net_namespace.h             |    3 +
>  include/net/netns/conntrack.h           |    6 ++
>  net/ipv6/netfilter/nf_conntrack_reasm.c |  135 +++++++++++++++++++++=
----------
>  3 files changed, 102 insertions(+), 42 deletions(-)
>=20
> diff --git a/include/net/net_namespace.h b/include/net/net_namespace.=
h
> index 5ae57f1..5c467bb 100644
> --- a/include/net/net_namespace.h
> +++ b/include/net/net_namespace.h
> @@ -93,6 +93,9 @@ struct net {
>  #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODU=
LE)
>  	struct netns_ct		ct;
>  #endif
> +#if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
> +	struct netns_nf_ct	nf_ct;
> +#endif

There's above one "struct netns_ct" that already encapsulates
netfilter conntrack netns parameters.

However, I'd prefer if, while at it, you define some struct
netns_nf_frag instead.

In net/ipv6/netfilter/Makefile, it says:

# defrag
nf_defrag_ipv6-y :=3D nf_defrag_ipv6_hooks.o nf_conntrack_reasm.o

Note that nf defragmentation is not glued to conntrack anymore. So I'd
go for one netns_nf_frag for this in include/net/net_namespace.h

Thanks.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
