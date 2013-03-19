From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 1/5] GRE: Refactor GRE tunneling code.
Date: Tue, 19 Mar 2013 10:19:27 -0400 (EDT)
Message-ID: <20130319.101927.283956963598107880.davem@davemloft.net>
References: <1363680615-1751-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jesse@nicira.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43066 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755363Ab3CSOTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 10:19:30 -0400
In-Reply-To: <1363680615-1751-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Tue, 19 Mar 2013 01:10:15 -0700

> @@ -0,0 +1,169 @@
> +#ifndef __NET_IP_TUNNELS_H
> +#define __NET_IP_TUNNELS_H 1
> +
> +#include <linux/if_tunnel.h>
> +#include <net/dsfield.h>
> +#include <net/gro_cells.h>
> +#include <net/inet_ecn.h>
> +#include <net/ip.h>
> +
> +/* Keep error state on tunnel for 30 sec */
> +#define IPTUNNEL_ERR_TIMEO	(30*HZ)
> +
> +/* 6rd prefix/relay information */
> +struct ip_tunnel_6rd_parm {
> +	struct in6_addr		prefix;

Please include <linux/in6.h> explicitly rather than getting the in6_addr
definition indirectly via linux/dsfield.h

Please audit the data types and interfaces used in the rest of this
header file and make sure all the proper includes are being explicitly
made.

Finally, if you haven't already, please do some sanity builds with
different combinations of IPV6 being on and off.

Thanks.
