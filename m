From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH nf-next] netfilter: constify nf_loginfo structures
Date: Wed, 2 Aug 2017 14:24:09 +0200
Message-ID: <20170802122409.GB13459@salvia>
References: <1501584483-999-1-git-send-email-Julia.Lawall@lip6.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org, coreteam@netfilter.org,
        netfilter-devel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
        Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
To: Julia Lawall <Julia.Lawall@lip6.fr>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1501584483-999-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 12:48:03PM +0200, Julia Lawall wrote:
> The nf_loginfo structures are only passed as the seventh argument to
> nf_log_trace, which is declared as const or stored in a local const
> variable.  Thus the nf_loginfo structures themselves can be const.
> 
> Done with the help of Coccinelle.
> 
> // <smpl>
> @r disable optional_qualifier@
> identifier i;
> position p;
> @@
> static struct nf_loginfo i@p = { ... };
> 
> @ok1@
> identifier r.i;
> expression list[6] es;
> position p;
> @@
>  nf_log_trace(es,&i@p,...)
> 
> @ok2@
> identifier r.i;
> const struct nf_loginfo *e;
> position p;
> @@
>  e = &i@p
> 
> @bad@
> position p != {r.p,ok1.p,ok2.p};
> identifier r.i;
> struct nf_loginfo e;
> @@
> e@i@p
> 
> @depends on !bad disable optional_qualifier@
> identifier r.i;
> @@
> static
> +const
>  struct nf_loginfo i = { ... };
> // </smpl>

Applied, thanks Julia.
