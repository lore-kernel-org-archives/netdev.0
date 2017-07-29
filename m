From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH 1/1] netfilter: constify nf_conntrack_l3/4proto parameters
Date: Sat, 29 Jul 2017 23:22:35 +0200
Message-ID: <20170729212235.GI28392@breakpoint.cc>
References: <1501356197-26490-1-git-send-email-Julia.Lawall@lip6.fr>
 <1501356197-26490-2-git-send-email-Julia.Lawall@lip6.fr>
 <20170729200343.GH28392@breakpoint.cc>
 <alpine.DEB.2.20.1707292208390.21384@hadrien>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: Florian Westphal <fw@strlen.de>,
        "David S. Miller" <davem@davemloft.net>, bhumirks@gmail.com,
        kernel-janitors@vger.kernel.org,
        Pablo Neira Ayuso <pablo@netfilter.org>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Julia Lawall <julia.lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1707292208390.21384@hadrien>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall <julia.lawall@lip6.fr> wrote:
> > I think we can indeed constify these completely after making
> > 'nla_size' set at compile time.
> >
> > I'll send a simple attempt to make it so for l3proto soon.
> 
> There is another issue with respect to nf_ct_l3proto_unregister.  This
> calls nf_ct_iterate_destroy with l3proto as the second argument.  This
> function has signature:
> 
> void
> nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)
> 
> The void * is not const.  Maybe it could be.

Haven't looked if we can constify it in general, but, as the argument
is not going to be written to in this particular case it will not be
a showstopper.
