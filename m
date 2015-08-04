From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2 1/2] openvswitch: Use regular GRE net_device
 instead of vport
Date: Mon, 3 Aug 2015 21:23:40 -0700
Message-ID: <20150804042339.GA47032@Alexeis-MBP.westell.com>
References: <1438648046-10346-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:36212 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbbHDEXp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2015 00:23:45 -0400
Received: by pdco4 with SMTP id o4so16884800pdc.3
        for <netdev@vger.kernel.org>; Mon, 03 Aug 2015 21:23:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1438648046-10346-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 03, 2015 at 05:27:26PM -0700, Pravin B Shelar wrote:
> With addition of flow based tunneling, there is no need to
> have special GRE vport. Removes all of the OVS specific
> GRE code and make OVS use a ip_gre net_device.
> Minimal GRE vport is kept to handle compatibility with
> current userspace application.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
...
> +#define GRE_TAP_FB_NAME "gretap0"
...
> +	/* fallback device is used for flow based tunneling. */
> +	if (!strcmp(dev->name, GRE_TAP_FB_NAME)) {
> +		struct ip_tunnel *t;
> +
> +		t = netdev_priv(dev);
> +		t->flow_based_tunnel = true;
> +		eth_hw_addr_random(dev);
> +		netif_keep_dst(dev);
> +	}
> +

feature detection based on netdev name?
meaning that there will be only one such device for the whole
host? and namespaces cannot have their own gre tunnels?
(since host 'gretap0' cannot be seen in netns)
