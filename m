From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ipvlan: Initial check-in of the IPVLAN
 driver.
Date: Tue, 18 Nov 2014 15:54:37 -0500 (EST)
Message-ID: <20141118.155437.1582768084232091503.davem@davemloft.net>
References: <1416205634-26611-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, maze@google.com,
	chavey@google.com, thockin@google.com, brandon.philips@coreos.com,
	xemul@parallels.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755238AbaKRUyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 15:54:41 -0500
In-Reply-To: <1416205634-26611-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Sun, 16 Nov 2014 22:27:14 -0800

> +/* Define IPVL_DEBUG and set the appropriate dbg_level for debugging. */
> +#ifdef	IPVL_DEBUG
> +/*
> + * 1 : non-datapath debugging
> + * 2 : Custom
> + * 3 : function enters and exists.
> + * 4 : printk in data path (be careful!)
> + */
> +#define IPVL_DBG_LEVEL 1
> +#define ipvlan_dbg(level, msg...)	do { \
> +						if (level <= IPVL_DBG_LEVEL) \
> +						printk(KERN_DEBUG msg); \
> +					} while (0)
> +#else
> +#define ipvlan_dbg(level, msg...) do { ; } while (0)
> +#endif

The day of having code use custom local debug logging facilities is long
gone, please use a standard mechanism for this rather than home cooked
reimplementations.

> +/* ---- Prototype declarations ---- */
> +/* ---- ipvlan_main.c ---- */

Everone knows these are prototype declarations by virtue of them being
functions declarations in a header file.

Anyone who wants to know where these are defined can run grep.

So these comments are superfluous, please remove them across this
entire submission.

> +	const struct in_addr *ip4_addr = iaddr;
> +	return jhash_1word(ip4_addr->s_addr, ipvlan_jhash_secret)
> +	       & IPVLAN_HASH_MASK;

When an expression spans multiple lines, lines end rather than begin
with an operator.

> +		if (is_v6 && addr->atype == IPVL_IPV6 &&
> +			ipv6_addr_equal(&addr->ip6addr, iaddr))

For multi-line if() statements, the second line and subsequent lines
must begine exactly at the first column after the openning parenthesis
of the first line.

If you are purely using TAB characters to indent, you are likely doing
it wrong.
> +		if ((is_v6 && addr->atype == IPVL_IPV6 &&
> +		     ipv6_addr_equal(&addr->ip6addr, iaddr))
> +		   || (!is_v6 && addr->atype == IPVL_IPV4 &&
> +		      addr->ip4addr.s_addr == ((struct in_addr *)iaddr)->s_addr)

Lines end, not begin, with operators.

> --- /dev/null
> +++ b/drivers/net/ipvlan/ipvlan_sysfs.c

Please do not add sysfs configuration knobs, netlink is sufficient.
