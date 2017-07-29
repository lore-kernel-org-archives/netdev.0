From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 1/1] netfilter: constify nf_conntrack_l3/4proto
 parameters
Date: Sat, 29 Jul 2017 22:18:38 +0200 (CEST)
Message-ID: <alpine.DEB.2.20.1707292208390.21384@hadrien>
References: <1501356197-26490-1-git-send-email-Julia.Lawall@lip6.fr> <1501356197-26490-2-git-send-email-Julia.Lawall@lip6.fr> <20170729200343.GH28392@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, bhumirks@gmail.com,
        kernel-janitors@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170729200343.GH28392@breakpoint.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Sat, 29 Jul 2017, Florian Westphal wrote:

> Julia Lawall <Julia.Lawall@lip6.fr> wrote:
> > When a nf_conntrack_l3/4proto parameter is not on the left hand side
> > of an assignment, its address is not taken, and it is not passed to a
> > function that may modify its fields, then it can be declared as const.
> >
> > This change is useful from a documentation point of view, and can
> > possibly facilitate making some nf_conntrack_l3/4proto structures const
> > subsequently.
> >
> > Done with the help of Coccinelle.
> >
> > Some spacing adjusted to fit within 80 characters.
>
> Acked-by: Florian Westphal <fw@strlen.de>
>
> Thanks Julia.
>
> I think we can indeed constify these completely after making
> 'nla_size' set at compile time.
>
> I'll send a simple attempt to make it so for l3proto soon.

There is another issue with respect to nf_ct_l3proto_unregister.  This
calls nf_ct_iterate_destroy with l3proto as the second argument.  This
function has signature:

void
nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)

The void * is not const.  Maybe it could be.

julia

> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
