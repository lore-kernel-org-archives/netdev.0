From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH] NETFILTER module xt_hmark new target for HASH MARK
Date: Thu, 03 Feb 2011 14:51:18 +0100
Message-ID: <4D4AB2D6.7070302@netfilter.org>
References: <1296740050-6311-1-git-send-email-hans.schillstrom@ericsson.com> <1296740050-6311-2-git-send-email-hans.schillstrom@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, jengelh@medozas.de,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	hans@schillstrom.com
To: Hans Schillstrom <hans.schillstrom@ericsson.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1296740050-6311-2-git-send-email-hans.schillstrom@ericsson.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/02/11 14:34, Hans Schillstrom wrote:
> +/*
> + * Calc hash value, special casre is taken on icmp and fragmented messages
> + * i.e. fragmented messages don't use ports.
> + */
> +static __u32 get_hash(struct sk_buff *skb, struct xt_hmark_info *info)
> +{
[...]
> +	ip_proto &= info->prmask;
> +	/* get a consistent hash (same value on both flow directions) */
> +	if (addr2 < addr1)
> +		swap(addr1, addr2);

this assumption is not valid in NAT handlings.

If you want consistent hashing with NAT handlings you'll have to make
this stateful and use the conntrack source and reply directions of the
original tuples (thus making it stateful). That may be a problem because
some people may want to use this without enabling connection tracking.

Are you using this for (uplink) load balancing?

Could you also include one realistic example in the patch description on
how this is used?

If this is accepted, I think this has to be merge with the (already
overloaded) MARK target.
