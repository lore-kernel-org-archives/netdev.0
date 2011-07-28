From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next PATCH 2/4] ixgbe: Reconfigure SR-IOV Init
Date: Wed, 27 Jul 2011 22:26:53 -0700 (PDT)
Message-ID: <20110727.222653.1937782529626247279.davem@davemloft.net>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
	<20110727221754.8435.99712.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com,
	jeffrey.t.kirsher@intel.com
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44689 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab1G1F04 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 01:26:56 -0400
In-Reply-To: <20110727221754.8435.99712.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Wed, 27 Jul 2011 15:17:54 -0700

> +	int i;
> +	for (i = 0; i < adapter->num_vfs; i++) {
> +		if (adapter->vfinfo[i].vfdev->dev_flags &
> +			PCI_DEV_FLAGS_ASSIGNED) {
> +		return true;
> +		}
> +	}

Bad formatting and indentation, please fix this.

> +		pvfdev = pci_get_device(IXGBE_INTEL_VENDOR_ID, device_id, NULL);
> +		while (pvfdev) {
> +			if (pvfdev->devfn == thisvf_devfn)
> +				break;
> +			pvfdev = pci_get_device(IXGBE_INTEL_VENDOR_ID,
> +						device_id, pvfdev);
> +		}
> +		if (pvfdev)
> +			adapter->vfinfo[vfn].vfdev = pvfdev;

pci_get_*() grabs a reference to any non-NULL pci device object
returned, where does this reference get released?  I scanned
all uses of x.vfdev and x->vfdev and could not find the necessary
release.

