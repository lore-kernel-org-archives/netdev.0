From: Joe Perches <joe@perches.com>
Subject: Re: netfilter 11/31: xtables: print hook name instead of mask
Date: Wed, 10 Jun 2009 13:22:11 -0700
Message-ID: <1244665331.895.25.camel@Joe-Laptop.home>
References: <20090610194621.11112.72922.sendpatchset@x2.localnet>
	 <20090610194635.11112.2127.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090610194635.11112.2127.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2009-06-10 at 21:46 +0200, Patrick McHardy wrote:
> Author: Jan Engelhardt <jengelh@medozas.de>
>     netfilter: xtables: print hook name instead of mask
> diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
> @@ -351,9 +377,13 @@ int xt_check_match(struct xt_mtchk_param *par,
>  		return -EINVAL;
>  	}
>  	if (par->match->hooks && (par->hook_mask & ~par->match->hooks) != 0) {
> -		printk("%s_tables: %s match: bad hook_mask %#x/%#x\n",
> +		char used[64], allow[64];
> +
> +		printk("%s_tables: %s match: used from hooks %s, but only "
> +		       "valid from %s\n",
>  		       xt_prefix[par->family], par->match->name,
> -		       par->hook_mask, par->match->hooks);
> +		       textify_hooks(used, sizeof(used), par->hook_mask),
> +		       textify_hooks(allow, sizeof(allow), par->match->hooks));
>  		return -EINVAL;
>  	}
>  	if (par->match->proto && (par->match->proto != proto || inv_proto)) {

Shouldn't all the printks in x_tables.c be pr_err or printk(KERN_ERR ?


