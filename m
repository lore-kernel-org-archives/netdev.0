From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Mon, 24 Jun 2013 11:16:37 -0700
Message-ID: <1372097797.1245.12.camel@joe-AO722>
References: <51C87746.1010002@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:53390 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752961Ab3FXSQk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Jun 2013 14:16:40 -0400
In-Reply-To: <51C87746.1010002@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-24 at 18:43 +0200, Arvid Brodin wrote:
> High-availability Seamless Redundancy ("HSR") provides instant failover
> redundancy for Ethernet networks. It requires a special network topology where
> all nodes are connected in a ring (each node having two physical network
> interfaces). It is suited for applications that demand high availability and
> very short reaction time.

trivia:

You should probably use checkpatch.pl --strict for files in net.
It will suggest aligning arguments in the more common net style.

>  net/hsr/hsr_device.h          |  30 +++
>  net/hsr/hsr_framereg.h        |  54 ++++
>  net/hsr/hsr_main.h            | 167 ++++++++++++
>  net/hsr/hsr_netlink.h         |  74 ++++++

Maybe some of these .h files should go into include/net/...

A future version of checkpatch may read all the include
files and exempt any CamelCase defines/typedefs/functions
from CamelCase warnings.

> +	if ((skb->protocol != htons(ETH_P_PRP)) ||
> +			(hsr_ethhdr->ethhdr.h_proto != htons(ETH_P_PRP))) {

Please align indents after the appropriate open parenthesis. 

	if (foo ||
	    bar) {

> +bool is_hsr_master(struct net_device *dev)
> +{
> +	if (!dev) {
> +		WARN_ON_ONCE(1);
> +		return 0;
> +	}
> +	if (!dev->netdev_ops) {
> +		WARN_ON_ONCE(1);
> +		return 0;
> +	}

probably better to combine and give a textual reason

> diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
[]
> +#define HSR_LIFE_CHECK_INTERVAL		 2000 /* ms */
> +#define HSR_NODE_FORGET_TIME		60000 /* ms */
> +#define HSR_ANNOUNCE_INTERVAL		  100 /* ms */

Odd alignment

> diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
[]
> +static const struct nla_policy hsr_genl_policy[HSR_A_MAX + 1] = {
> +	[HSR_A_NODE_ADDR] = { .type = NLA_BINARY, .len = ETH_ALEN },
> +	[HSR_A_NODE_ADDR_B] = { .type = NLA_BINARY, .len = ETH_ALEN },
> +	[HSR_A_IFINDEX] = { .type = NLA_U32 },
> +	[HSR_A_IF1_AGE] = { .type = NLA_U32 }, /* Actually signed 32-bit */
> +	[HSR_A_IF2_AGE] = { .type = NLA_U32 }, /* Actually signed 32-bit */

Why not use NLA_S32?
