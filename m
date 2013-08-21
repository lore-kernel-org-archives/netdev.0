From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v3] net/hsr: Add support for the High-availability
 Seamless Redundancy protocol (HSRv0)
Date: Wed, 21 Aug 2013 12:01:20 -0700
Message-ID: <1377111680.1936.45.camel@joe-AO722>
References: <521504E1.5060309@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>,
	David Miller <davem@davemloft.net>
To: Arvid Brodin <arvid.brodin@xdin.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:46780 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752413Ab3HUTBV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Aug 2013 15:01:21 -0400
In-Reply-To: <521504E1.5060309@xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-08-21 at 20:20 +0200, Arvid Brodin wrote:
> High-availability Seamless Redundancy ("HSR") provides instant failover
> redundancy for Ethernet networks. It requires a special network topology where
> all nodes are connected in a ring (each node having two physical network
> interfaces). It is suited for applications that demand high availability and
> very short reaction time.

Hi Arvid.

just trivia:

> diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
[]
> +static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
[]
> +	if (likely(res1 == NET_XMIT_SUCCESS || res1 == NET_XMIT_CN ||
> +		   res2 == NET_XMIT_SUCCESS || res2 == NET_XMIT_CN)) {

This might be faster using | instead of ||

[]

> diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
[]
> +
> +/* above(a, b) - return 1 if a > b, 0 otherwise.
> + */
> +static bool above(u16 a, u16 b)
> +{
> +	/* Remove inconsistency where above(a, b) == below(a, b) */
> +	if ((int) b - a == 32768)
> +		return 0;
> +
> +	return (((s16) (b - a)) < 0);
> +}
> +#define below(a, b)		above((b), (a))
> +#define above_or_eq(a, b)	(!below((a), (b)))
> +#define below_or_eq(a, b)	(!above((a), (b)))

These may be overly generic macro names given
these only take u16.
