From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/9] net: dsa: Add support for parsing the old
 binding
Date: Sat, 4 Jun 2016 22:00:16 +0200
Message-ID: <20160604200016.GD2063@lunn.ch>
References: <1464998733-10405-1-git-send-email-f.fainelli@gmail.com>
 <1464998733-10405-5-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com, john@phrozen.org
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59624 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750740AbcFDUAT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jun 2016 16:00:19 -0400
Content-Disposition: inline
In-Reply-To: <1464998733-10405-5-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -static int dsa_cpu_parse(struct device_node *port, u32 index,
> -			 struct dsa_switch_tree *dst,
> -			 struct dsa_switch *ds)
> +static int _dsa_cpu_parse(struct dsa_switch_tree *dst,
> +			   struct dsa_switch *ds,
> +			   struct net_device *ethernet_dev,
> +			   u32 index)
>  {
> -	struct net_device *ethernet_dev;
> -	struct device_node *ethernet;
> -
> -	ethernet = of_parse_phandle(port, "ethernet", 0);
> -	if (!ethernet)
> -		return -EINVAL;
> -
> -	ethernet_dev = of_find_net_device_by_node(ethernet);
> -	if (!ethernet_dev)
> -		return -EPROBE_DEFER;
> -

Hi Florian

You have just removed all the actual DT parsing. So i would give this
a different name, and avoid the _ prefix.

> +static int _dsa_register_switch_legacy(struct dsa_switch *ds, struct device_node *np)
> +{

We might want to call this _dsa_register_switch_legacy_sf2, since the
code only supports what is needed for your rather odd sf2 binding. It
does not appear to work for the generic DSA binding.

>  static int __dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
>  {
>  	struct device_node *ports = dsa_get_ports(ds, np);
> @@ -626,8 +736,8 @@ static int _dsa_register_switch(struct dsa_switch *ds, struct device_node *np)
>  {
>  	struct device_node *ports = dsa_get_ports(ds, np);
>  
> -	if (IS_ERR(ports))
> -		return PTR_ERR(ports);
> +	if (IS_ERR(ports) && PTR_ERR(ports) == -EINVAL)
> +		return _dsa_register_switch_legacy(ds, np);

Maybe put this inside if config_enabled(CONFIG_NET_DSA_BCM_SF2)  {}?

      Andrew
