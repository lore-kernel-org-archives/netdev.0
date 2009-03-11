From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Tue, 10 Mar 2009 21:18:41 -0700
Message-ID: <20090310211841.388619ca@nehalam>
References: <1236738549-16703-1-git-send-email-yanok@emcraft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	s.hauer@pengutronix.de, wd@denx.de, dzu@denx.de,
	Ilya Yanok <yanok@emcraft.com>
To: Ilya Yanok <yanok@emcraft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:35116 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751017AbZCKESu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2009 00:18:50 -0400
In-Reply-To: <1236738549-16703-1-git-send-email-yanok@emcraft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 11 Mar 2009 05:29:09 +0300
Ilya Yanok <yanok@emcraft.com> wrote:

> +static char ethaddr[18];
> +
> +module_param_string(ethaddr, ethaddr, sizeof(ethaddr), 0);
> +
> +static void get_mac_addr(struct net_device *nd, unsigned char *pmac)
> +{
> +	int i;
> +	char *p = ethaddr;
> +
> +	ethaddr[17] = 0;
> +	for (i = 0; i < ETH_ALEN; i++, p++) {
> +		pmac[i] = simple_strtoul(p, &p, 16);
> +		if (*p != ':')
> +			break;
> +	}
> +	if (i != ETH_ALEN - 1) {
> +		pr_err("Wrong MAC address format!\n");
> +		memset(pmac, 0, ETH_ALEN);
> +	}
> +}
> +

Do you still need this? Only works with one board, configuration via
module parameters is discouraged.  Same effect can be done by setting
mac address with regular tools.
