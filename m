From: Patrick McHardy <kaber@trash.net>
Subject: Re: [DECNET] Fix to multiple tables routing
Date: Fri, 11 Aug 2006 17:22:17 +0200
Message-ID: <44DCA0A9.7010800@trash.net>
References: <20060811142742.GA31748@souterrain.chygwyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick Caulfield <patrick@tykepenguin.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:20897 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1750814AbWHKPWW
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Aug 2006 11:22:22 -0400
To: Steven Whitehouse <steve@chygwyn.com>
In-Reply-To: <20060811142742.GA31748@souterrain.chygwyn.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Steven Whitehouse wrote:
> Here is a fix to Patrick McHardy's increase number of routing tables patch
> for DECnet. I did just test this and it appears to be working fine with
> this patch.
> 
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: Patrick Caulfield <patrick@tykepenguin.com>
> Signed-off-by: Steven Whitehouse <steve@chygwyn.com>
> 
> diff --git a/net/decnet/dn_rules.c b/net/decnet/dn_rules.c
> index 878312f..c8d9411 100644
> --- a/net/decnet/dn_rules.c
> +++ b/net/decnet/dn_rules.c
> @@ -116,6 +116,7 @@ static struct nla_policy dn_fib_rule_pol
>  	[FRA_SRC]	= { .type = NLA_U16 },
>  	[FRA_DST]	= { .type = NLA_U16 },
>  	[FRA_FWMARK]	= { .type = NLA_U32 },
> +	[FRA_TABLE]     = { .type = NLA_U32 },
>  };

Looks good. BTW, I noticed something in the DecNET fib_rule conversion
that looks like a bug:

The policy includes this for FRA_SRC/FRA_DST:

        [FRA_SRC]       = { .type = NLA_U16 },
        [FRA_DST]       = { .type = NLA_U16 },

But in dn_fib_rule_compare it is used like this:

        if (tb[FRA_SRC] && (r->src != nla_get_u32(tb[FRA_SRC])))
                return 0;

        if (tb[FRA_DST] && (r->dst != nla_get_u32(tb[FRA_DST])))
                return 0;

I think this might create problems depending on the endianness.
