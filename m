From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 3/7] net: dsa: mv88e6xxx: add switch info
Date: Sat, 16 Apr 2016 01:55:58 +0200
Message-ID: <20160415235558.GC32136@lunn.ch>
References: <1460762488-2633-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1460762488-2633-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58169 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751980AbcDOX4C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2016 19:56:02 -0400
Content-Disposition: inline
In-Reply-To: <1460762488-2633-4-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +	for (i = 0, info = &table[i]; i < num; info = &table[++i])
> +		if (info->prod_num == (id & 0xfff0) >> 4)
> +			goto found;
>  
>  	return NULL;
> -}
>  
> -char *mv88e6xxx_drv_probe(struct device *dsa_dev, struct device *host_dev,
> -			  int sw_addr, void **priv,
> -			  const struct mv88e6xxx_switch_id *table,
> -			  unsigned int num)
> -{
> -	struct mv88e6xxx_priv_state *ps;
> -	struct mii_bus *bus = dsa_host_dev_to_mii_bus(host_dev);
> -	char *name;
> -
> -	if (!bus)
> +found:
> +	ps = devm_kzalloc(dsa_dev, sizeof(*ps), GFP_KERNEL);
> +	if (!ps)


This looks like a goto to jump around a return NULL. Ugly.  I would
keep this lookup in a separate function. You can then avoid ugly stuff
like this.

CodingStyle says:

                Chapter 6: Functions

Functions should be short and sweet, and do just one thing.  They should
fit on one or two screenfuls of text (the ISO/ANSI screen size is 80x24,
as we all know), and do one thing and do that well.

   Andrew
