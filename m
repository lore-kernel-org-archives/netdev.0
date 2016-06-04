From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/9] net: dsa: Add support for parsing the old
 binding
Date: Sat, 4 Jun 2016 21:44:20 +0200
Message-ID: <20160604194420.GC2063@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59615 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750833AbcFDToW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 15:44:22 -0400
Content-Disposition: inline
In-Reply-To: <1464998733-10405-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -626,8 +736,8 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
>  {
>  	struct device_node *ports = dsa_get_ports(ds, np);
>  
> -	if (IS_ERR(ports))
> -		return PTR_ERR(ports);
> +	if (IS_ERR(ports) && PTR_ERR(ports) == -EINVAL)
> +		return _dsa_register_switch_legacy(ds, np);
>  
>  	return __dsa_register_switch(ds, np);
>  }

Hi Florian

Could you put this into dsa_register_switch() and so avoid all the __
prefixes.

Thanks
	Andrew
