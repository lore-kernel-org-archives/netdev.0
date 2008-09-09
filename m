From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/33] netns ct: per-netns expectations
Date: Tue, 09 Sep 2008 07:49:34 +0200
Message-ID: <48C60E6E.5080905@trash.net>
References: <48C01046.2070704@trash.net> <1220842990-30500-5-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1220842990-30500-5-git-send-email-adobriyan@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Make per-netns a) expectation hash and b) expectations count.
> 
> Expectations always belongs to netns to which it's master conntrack belong.
> This is natural and doesn't bloat expectation.
> 
> Proc files and leaf users are stubbed to init_net, this is temporary.

Looks fine, applied.

> @@ -406,7 +404,7 @@ int nf_ct_expect_related(struct nf_conntrack_expect *expect)
>  		}
>  	}
>  
> -	if (nf_ct_expect_count >= nf_ct_expect_max) {
> +	if (net->ct.expect_count >= nf_ct_expect_max) {
>  		if (net_ratelimit())
>  			printk(KERN_WARNING
>  			       "nf_conntrack: expectation table full\n");

I assume these message are globally visible even with namespaces?
Can we make this (and the corresponding ct hash message) refer to
the namespace? Otherwise it might be a bit confusing.
