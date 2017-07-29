From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 0/2] constify nf_hook_ops structures
Date: Sat, 29 Jul 2017 11:56:47 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1707291154470.2002@hadrien>
References: <1501310455-7896-1-git-send-email-Julia.Lawall@lip6.fr> <20170729084429.GE28392@breakpoint.cc> <alpine.DEB.2.20.1707291049370.2002@hadrien> <20170729091618.GF28392@breakpoint.cc> <alpine.DEB.2.20.1707291120580.2002@hadrien>
 <20170729094136.GG28392@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Julia Lawall <julia.lawall@lip6.fr>,
        linux-decnet-user@lists.sourceforge.net, bhumirks@gmail.com,
        kernel-janitors@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        "David S. Miller" <davem@davemloft.net>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170729094136.GG28392@breakpoint.cc>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 29 Jul 2017, Florian Westphal wrote:

> Julia Lawall <julia.lawall@lip6.fr> wrote:
> > On Sat, 29 Jul 2017, Florian Westphal wrote:
> > > From a quick glance I don't see why we can't e.g. constify
> > > nf_conntrack_l3/4_proto too. It is not going to be as simple
> > > as just placing const everywhere, but I see no requirement for
> > > having these writeable.
> >
> > I will take a look.
>
> Thanks.

For the protos, the functions nf_ct_l3proto_register and
nf_ct_l4proto_register_one update the nla_size field. I don't know how
many structures reach these functions.

julia

>
> nf_logger and nf_loginfo also look like constify candidates.
>
> If there is a way to add "const" qualifier to pointer-to-structs
> that are not modified this would good as well to have IMO, if just
> for purpose of documentation.  For instance:
>
> +++ b/net/netfilter/nf_conntrack_core.c
> @@ -1177,8 +1177,8 @@ void nf_conntrack_free(struct nf_conn *ct)
>  static noinline struct nf_conntrack_tuple_hash *
>  init_conntrack(struct net *net, struct nf_conn *tmpl,
>                const struct nf_conntrack_tuple *tuple,
> -              struct nf_conntrack_l3proto *l3proto,
> -              struct nf_conntrack_l4proto *l4proto,
> +              const struct nf_conntrack_l3proto *l3proto,
> +              const struct nf_conntrack_l4proto *l4proto,
>
>
> (its only passed as arg to a function that expects
> "const struct nf_conntrack_x *").
>
> I think we have several (also non-static helpers) that
> take "struct foo *" arg while they could use "const struct foo*"
> instead.
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
