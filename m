From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] ixgbe: Look up MAC address in Open Firmware
Date: Fri, 14 Nov 2014 14:23:25 -0800
Message-ID: <546680DD.7030708@gmail.com>
References: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux.nics@intel.com
To: "Martin K. Petersen" <martin.petersen@oracle.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:40921 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161814AbaKNWXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2014 17:23:36 -0500
Received: by mail-pa0-f50.google.com with SMTP id eu11so18346767pac.37
        for <netdev@vger.kernel.org>; Fri, 14 Nov 2014 14:23:36 -0800 (PST)
In-Reply-To: <yq1r3x5vbh9.fsf@sermon.lab.mkp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/14/2014 11:16 AM, Martin K. Petersen wrote:

[snip]

> +#ifdef CONFIG_OF
> +/**
> + * ixgbe_of_mac_addr - Look up MAC address in Open Firmware
> + * @adapter: Pointer to adapter struct
> + */
> +static void ixgbe_of_mac_addr(struct ixgbe_adapter *adapter)
> +{
> +	struct device_node *dp = pci_device_to_OF_node(adapter->pdev);
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	const unsigned char *addr;
> +	int len;
> +
> +	addr = of_get_property(dp, "local-mac-address", &len);
> +	if (addr && len == 6) {
> +		e_dev_info("Using OpenPROM MAC address\n");
> +		memcpy(hw->mac.perm_addr, addr, 6);
> +	}

Cannot you use of_get_mac_address() here which does iterate through all
the OF standard ways to specify a MAC address: mac-address,
local-mac-address and address? Benefit is that this will work for all
DT-enabled platforms.

> +
> +	if (!is_valid_ether_addr(hw->mac.perm_addr)) {
> +		e_dev_info("Using IDPROM MAC address\n");
> +		memcpy(hw->mac.perm_addr, idprom->id_ethaddr, 6);
> +	}
> +}
> +#endif
> +
>  /**
>   * ixgbe_probe - Device Initialization Routine
>   * @pdev: PCI device information struct
> @@ -8223,6 +8253,10 @@ skip_sriov:
>  		goto err_sw_init;
>  	}
>  
> +#ifdef CONFIG_OF
> +	ixgbe_of_mac_addr(adapter);
> +#endif
> +
>  	memcpy(netdev->dev_addr, hw->mac.perm_addr, netdev->addr_len);
>  
>  	if (!is_valid_ether_addr(netdev->dev_addr)) {
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
