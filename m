From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 13/19] netfilter: ip6tables: add MASQUERADE target
Date: Sat, 18 Aug 2012 14:31:01 +0200 (MEST)
Message-ID: <Pine.GSO.4.63.1208181428110.17600@stinky-local.trash.net>
References: <1344542943-11588-1-git-send-email-kaber@trash.net>
 <1344542943-11588-14-git-send-email-kaber@trash.net> <20120817131157.GA23832@1984>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54225 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750739Ab2HRMbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Aug 2012 08:31:03 -0400
In-Reply-To: <20120817131157.GA23832@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 17 Aug 2012, Pablo Neira Ayuso wrote:

> Hi Patrick,
>
> On Thu, Aug 09, 2012 at 10:08:57PM +0200, kaber@trash.net wrote:
>> From: Patrick McHardy <kaber@trash.net>
>>
> Please, add this chunk to this patch:
>
> diff --git a/include/net/netfilter/nf_nat.h
> b/include/net/netfilter/nf_nat.h
> index 1752f133..bd8eea7 100644
> --- a/include/net/netfilter/nf_nat.h
> +++ b/include/net/netfilter/nf_nat.h
> @@ -43,7 +43,9 @@ struct nf_conn_nat {
>        struct nf_conn *ct;
>        union nf_conntrack_nat_help help;
> #if defined(CONFIG_IP_NF_TARGET_MASQUERADE) || \
> -    defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE)
> +    defined(CONFIG_IP_NF_TARGET_MASQUERADE_MODULE) || \
> +    defined(CONFIG_IP6_NF_TARGET_MASQUERADE) || \
> +    defined(CONFIG_IP6_NF_TARGET_MASQUERADE_MODULE)
>        int masq_index;
> #endif
> };
>
> Otherwise, compilation breaks with:
>
> * IPv4 NAT is disabled
> * IPv6 NAT enabled.

Fixed, thanks.

>
> And yes, that pile of ifdefs is really ugly, I wonder if they are
> worth for saving 4 bytes. I think most vendors usually include
> MASQUERADE support if NAT is enabled.
>
> It seems we have the tradition of keeping several similar compile time
> options in Netfilter to optimize memory in several situations (at the
> cost of polluting the code with ifdefs). Probably we can think of
> getting rid of them.

Well, vendors maybe, but what about embedded systems? I have some which
are *really* short on memory. They limit conntrack to very few entries
though, so it doesn't make that much of a difference.
