From: Patrick McHardy <kaber@trash.net>
Subject: Re: unlock iptables in netns
Date: Wed, 11 Jun 2008 08:53:23 +0200
Message-ID: <484F7663.1080408@trash.net>
References: <200806102127.21093.adobriyan@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org, den@openvz.org, xemul@openvz.org,
	adobriyan@gmail.com
To: Alexey Dobriyan <adobriyan@parallels.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <200806102127.21093.adobriyan@parallels.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Alexey Dobriyan wrote:
> Hi,
> 
> Den basically banned iptables in netns via this patch
> 
> --- a/net/netfilter/core.c
> +++ b/net/netfilter/core.c
> ...
> , however, at least some of netfilter pieces are ready for usage in netns
> and it would be nice to unlock them before release.
> 
> If I'm deciphering chengelog correctly it's all about code which does
> nf_register_hook{,s} but not netns-ready itself:
> 
> 	br_netfilter.c
> 	iptable_mangle (via ip_route_me_harder)
> 	conntracking (both IPv4 and IPv6)
> 	NAT
> 	arptable_filter
> 	selinux
> 	decnet
> 	ebtable_filter
> 	ebtable_nat
> 	ipt_CLUSTERIP
> 
> Patch above can be applied and we can mark above list as "depends !NET_NS"
> and move on.
> 
> Comments? Den, was there something else you're afraid of?


That might result in some bad surprises for people how have already
turned on NET_NS. I'd prefer a way that doesn't potentially disable
half the netfilter options in existing configs.


