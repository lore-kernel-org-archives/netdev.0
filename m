From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][v6] netlink: have netlink per-protocol bind function
 return an error code.
Date: Wed, 26 Mar 2014 23:13:42 +0000
Message-ID: <20140326231342.GA22381@macbook.localnet>
References: <20140324183406.GE28666@madcap2.tricolour.ca>
 <32971f5def3bebff26650bc088c6f3f21f3c727b.1395751443.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-audit@redhat.com, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	eparis@redhat.com, sgrubb@redhat.com, hadi@mojatatu.com,
	davem@davemloft.net
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <32971f5def3bebff26650bc088c6f3f21f3c727b.1395751443.git.rgb@redhat.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 25, 2014 at 08:50:56AM -0400, Richard Guy Briggs wrote:
> +	if (nlk->netlink_bind && nladdr->nl_groups) {
> +		int i;
> +
> +		for (i = 0; i < nlk->ngroups; i++)
> +			if (test_bit(i, (long unsigned int *)&nladdr->nl_groups)) {
> +				err = nlk->netlink_bind(i);
> +				if (err) {
> +					int undo;
> +					if (!nlk->portid)
> +						netlink_remove(sk);
> +					for (undo = 0; undo < i; undo++)
> +						if (nlk->netlink_unbind)
> +							nlk->netlink_unbind(undo);

Do we really need 7 levels of indentation? You could save at least
one by using

if (!test_bit(...)
	continue;
...

Or maybe simply move this to a helper function.



> +					return err;
> +				}
> +			}
> +	}
> +
>  	netlink_table_grab();
>  	netlink_update_subscriptions(sk, nlk->subscriptions +
>  					 hweight32(nladdr->nl_groups) -
