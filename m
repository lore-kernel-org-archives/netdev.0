From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] Fix bug where remove of device fails to free all
 resources.
Date: Thu, 03 Mar 2016 16:51:12 -0500 (EST)
Message-ID: <20160303.165112.628368221794213474.davem@davemloft.net>
References: <1456864492-32257-1-git-send-email-dougmill@linux.vnet.ibm.com>
	<1456864492-32257-2-git-send-email-dougmill@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
	ajit.khaparde@broadcom.com, padmanabh.ratnakar@broadcom.com,
	sriharsha.basavapatna@broadcom.com, somnath.kotur@broadcom.com
To: dougmill@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48004 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753954AbcCCVvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 16:51:15 -0500
In-Reply-To: <1456864492-32257-2-git-send-email-dougmill@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Douglas Miller <dougmill@linux.vnet.ibm.com>
Date: Tue,  1 Mar 2016 14:34:52 -0600

> The adapter->pcicfg resource is either mapped via pci_iomap() or
> derived from adapter->db. During be_remove() this resource was ignored
> and so could remain mapped after remove.
> 
> Add a flag to track whether adapter->pcicfg was mapped or not, then
> use that flag in be_unmap_pci_bars() to unmap if required.
> 
> Signed-off-by: Douglas Miller <dougmill@linux.vnet.ibm.com>

You subject line need to mention the most relevant subsystem that your
change is too, otherwise people scanning the shortlog have no idea
where your change is taking place.

And your description needs to be more concise.

In this instance an appropriate Subject line would be:

	[PATCH] be2net: Don't leak iomapped memory on removal.

> @@ -5019,8 +5021,10 @@ static int be_map_pci_bars(struct be_adapter *adapter)
>  			if (!addr)
>  				goto pci_map_err;
>  			adapter->pcicfg = addr;
> +			adapter->pcicfg_mapped = 1;
>  		} else {
>  			adapter->pcicfg = adapter->db + SRIOV_VF_PCICFG_OFFSET;
> +			adapter->pcicfg_mapped = 0;
>  		}

Bool variables take on the values "true" and "false" so please use them.
