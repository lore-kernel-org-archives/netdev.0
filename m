From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [RFC PATCH net-next 04/20] net: dsa: mv88e6xxx: factorize
 temperature access
Date: Fri, 6 May 2016 01:40:33 +0200
Message-ID: <20160505234033.GJ7972@lunn.ch>
References: <1462488064-1841-1-git-send-email-vivien.didelot@savoirfairelinux.com>
 <1462488064-1841-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:57995 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754614AbcEEXkg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2016 19:40:36 -0400
Content-Disposition: inline
In-Reply-To: <1462488064-1841-5-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>  int mv88e6xxx_get_temp(struct dsa_switch *ds, int *temp)
>  {
>  	struct mv88e6xxx_priv_state *ps = ds_to_priv(ds);
> +	int err;
> +
> +	if (!mv88e6xxx_has(ps, MV88E6XXX_FLAG_TEMP))
> +		return -EOPNOTSUPP;
> +
> +	mutex_lock(&ps->smi_mutex);
>  
>  	if (mv88e6xxx_6320_family(ps) || mv88e6xxx_6352_family(ps))
> -		return mv88e63xx_get_temp(ds, temp);
> +		err = _mv88e63xx_get_temp(ps, temp);
> +	else
> +		err = _mv88e61xx_get_temp(ps, temp);

It seems like this should be done with a flag, rather than the family.

However, don't spend too much time on this. I plan to rip it all out
and put it in the correct place, in the Marvell PHY driver. The
temperature sensor is in the PHY, and other Marvell PHYs also have
this temperature sensor.

     Andrew
