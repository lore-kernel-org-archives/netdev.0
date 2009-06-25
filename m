From: Brandon Philips <brandon@ifup.org>
Subject: Re: [PATCH] atl1*: add device_set_wakeup_enable to atl1*_set_wol
Date: Wed, 24 Jun 2009 17:37:27 -0700
Message-ID: <20090625003727.GA14726@jenkins.home.ifup.org>
References: <20090625000914.GL3648@jenkins.smartcity.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jcliburn@gmail.com, csnook@redhat.com, jie.yang@atheros.com,
	rjw@sisk.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f190.google.com ([209.85.216.190]:33937 "EHLO
	mail-px0-f190.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751270AbZFYAqg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jun 2009 20:46:36 -0400
Received: by pxi28 with SMTP id 28so672449pxi.33
        for <netdev@vger.kernel.org>; Wed, 24 Jun 2009 17:46:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090625000914.GL3648@jenkins.smartcity.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BTW, Chris Snook's email address bounced. Can someone with a newer
address update MAINTAINERS?

On 17:09 Wed 24 Jun 2009, Brandon Philips wrote:
> Tell PCI core that atl1* device can wakeup the system when WOL is
> enabled by calling device_set_wakeup_enable. 
> 
> Joerg noted that his atl1e device WOL fine after enabling it with
> ethtool and changing /sys/class/net/eth0/device/power/wakeup to enabled
> Tested on atl1e: https://bugzilla.novell.com/show_bug.cgi?id=493214
> 
> Tested by: Joerg Reuter <jreuter@novell.com>
> Signed-off-by: Brandon Philips <bphilips@suse.de>
> 
> ---
>  drivers/net/atl1c/atl1c_ethtool.c |    2 ++
>  drivers/net/atl1e/atl1e_ethtool.c |    2 ++
>  2 files changed, 4 insertions(+)
> 
> Index: linux-2.6/drivers/net/atl1e/atl1e_ethtool.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/atl1e/atl1e_ethtool.c
> +++ linux-2.6/drivers/net/atl1e/atl1e_ethtool.c
> @@ -365,6 +365,8 @@ static int atl1e_set_wol(struct net_devi
>  	if (wol->wolopts & WAKE_PHY)
>  		adapter->wol |= AT_WUFC_LNKC;
>  
> +	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
> +
>  	return 0;
>  }
>  
> Index: linux-2.6/drivers/net/atl1c/atl1c_ethtool.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/atl1c/atl1c_ethtool.c
> +++ linux-2.6/drivers/net/atl1c/atl1c_ethtool.c
> @@ -281,6 +281,8 @@ static int atl1c_set_wol(struct net_devi
>  	if (wol->wolopts & WAKE_PHY)
>  		adapter->wol |= AT_WUFC_LNKC;
>  
> +	device_set_wakeup_enable(&adapter->pdev->dev, adapter->wol);
> +
>  	return 0;
>  }
>  
