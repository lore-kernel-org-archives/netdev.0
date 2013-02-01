From: Joe Perches <joe@perches.com>
Subject: Re: [net-next 01/11] ixgbe: Reset the NIC if up2tc has changed
Date: Fri, 01 Feb 2013 00:02:34 -0800
Message-ID: <1359705754.17807.5.camel@joe-AO722>
References: <1359705211-11342-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1359705211-11342-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, Amir Hanania <amir.hanania@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:48266 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751098Ab3BAICg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2013 03:02:36 -0500
In-Reply-To: <1359705211-11342-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-01-31 at 23:53 -0800, Jeff Kirsher wrote:
> From: Amir Hanania <amir.hanania@intel.com>
[]
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_dcb_nl.c
[]
> @@ -542,6 +540,7 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
>  	int max_frame = dev->mtu + ETH_HLEN + ETH_FCS_LEN;
>  	int i, err = 0;
>  	__u8 max_tc = 0;

This should really be int

> +	__u8 map_chg = 0;

Please use bool/true/false where appropriate.

> @@ -551,15 +550,22 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
[]
> +		if (ets->prio_tc[i] != adapter->ixgbe_ieee_ets->prio_tc[i])
> +			map_chg = 1;
[]
> @@ -568,6 +574,8 @@ static int ixgbe_dcbnl_ieee_setets(struct net_device *dev,
>  
>  	if (max_tc != netdev_get_num_tc(dev))
>  		err = ixgbe_setup_tc(dev, max_tc);
> +	else if (map_chg)
> +		ixgbe_dcbnl_devreset(dev);
