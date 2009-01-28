From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFT 2/4] netfilter: remove unneeded initializations
Date: Wed, 28 Jan 2009 03:10:32 +0300
Message-ID: <20090128001032.GA4034@x200.localdomain>
References: <20090127235310.159946902@vyatta.com> <20090127235508.827819940@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.154]:17026 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751038AbZA1AEx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 19:04:53 -0500
Content-Disposition: inline
In-Reply-To: <20090127235508.827819940@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 03:53:12PM -0800, Stephen Hemminger wrote:
> Later patches change the locking on xt_table and the initialization of
> the lock element is not needed since the lock is always initialized in
> xt_table_register anyway.

>  net/ipv4/netfilter/arptable_filter.c   |    2 --
>  net/ipv4/netfilter/iptable_filter.c    |    1 -
>  net/ipv4/netfilter/iptable_mangle.c    |    1 -
>  net/ipv4/netfilter/iptable_raw.c       |    1 -
>  net/ipv4/netfilter/iptable_security.c  |    1 -
>  net/ipv4/netfilter/nf_nat_rule.c       |    1 -
>  net/ipv6/netfilter/ip6table_filter.c   |    1 -
>  net/ipv6/netfilter/ip6table_mangle.c   |    1 -
>  net/ipv6/netfilter/ip6table_raw.c      |    1 -
>  net/ipv6/netfilter/ip6table_security.c |    1 -
>  10 files changed, 11 deletions(-)
> 
> --- a/net/ipv4/netfilter/arptable_filter.c
> +++ b/net/ipv4/netfilter/arptable_filter.c
> @@ -48,8 +48,6 @@ static struct
>  static struct xt_table packet_filter = {
>  	.name		= "filter",
>  	.valid_hooks	= FILTER_VALID_HOOKS,
> -	.lock		= __RW_LOCK_UNLOCKED(packet_filter.lock),

ACK and you can do the same for ebt_register_table() users.
