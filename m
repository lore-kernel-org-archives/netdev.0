From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch 1/1] net/netfilter/nf_conntrack_netlink.c: fix Oops on
 container destroy
Date: Tue, 1 Nov 2011 09:07:15 +0100
Message-ID: <20111101080715.GA4268@1984>
References: <201110312133.p9VLXDUu003535@hpaq6.eem.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, alex@alex.org.uk,
	stable@kernel.org, stable@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201110312133.p9VLXDUu003535@hpaq6.eem.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 31, 2011 at 02:33:12PM -0700, akpm@linux-foundation.org wrote:
> diff -puN net/netfilter/nf_conntrack_netlink.c~net-netfilter-nf_conntrack_netlinkc-fix-oops-on-container-destroy net/netfilter/nf_conntrack_netlink.c
> --- a/net/netfilter/nf_conntrack_netlink.c~net-netfilter-nf_conntrack_netlinkc-fix-oops-on-container-destroy
> +++ a/net/netfilter/nf_conntrack_netlink.c
> @@ -570,6 +570,11 @@ ctnetlink_conntrack_event(unsigned int e
>  		return 0;
>  
>  	net = nf_ct_net(ct);
> +
> +	/* container deinit, netlink may have died before death_by_timeout */
> +	if (!net->nfnl)
> +		return 0;
> +

This patch is a workaround and it is incomplete (it doesn't include
the expectation part). The correct fix requires to finish container
support for nfnetlink, which seems incomplete.

I was expecting some feedback from Alexey Dobriyan with no success.

If we apply this, we'll have to apply similar workaround in other
parts of the code.
