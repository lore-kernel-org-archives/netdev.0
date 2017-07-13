From: Sinan Kaya <okaya@codeaurora.org>
Subject: Re: [PATCH v7 2/3] PCI: Enable PCIe Relaxed Ordering if supported
Date: Thu, 13 Jul 2017 17:09:55 -0400
Message-ID: <e496ff1d-b836-ebef-fdf7-76273aaaaef6@codeaurora.org>
References: <1499955692-26556-1-git-send-email-dingtianhong@huawei.com>
 <1499955692-26556-3-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Ding Tianhong <dingtianhong@huawei.com>, leedom@chelsio.com,
        ashok.raj@intel.com, bhelgaas@google.com, helgaas@kernel.org,
        werner@chelsio.com, ganeshgr@chelsio.com, asit.k.mallick@intel.com,
        patrick.j.cramer@intel.com, Suravee.Suthikulpanit@amd.com,
        Bob.Shaw@amd.com, l.stach@pengutronix.de, amira@mellanox.com,
        gabriele.paoloni@huawei.com, David.Laight@aculab.com,
        jeffrey.t.kirsher@intel.com, catalin.marinas@arm.com,
        will.deacon@arm.com, mark.rutland@arm.com, robin.murphy@arm.com,
        davem@davemloft.net, alexander.duyck@gmail.com,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-pci@vger.kernel.org, linux-kernel@vger.kernel.org,
        linuxarm@huawei.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1499955692-26556-3-git-send-email-dingtianhong@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 7/13/2017 10:21 AM, Ding Tianhong wrote:
> static void pci_configure_relaxed_ordering(struct pci_dev *dev)
> +{
> +	/* We should not alter the relaxed ordering bit for the VF */
> +	if (dev->is_virtfn)
> +		return;
> +
> +	/* If the releaxed ordering enable bit is not set, do nothing. */
> +	if (!pcie_relaxed_ordering_supported(dev))
> +		return;
> +
> +	if (pci_dev_should_disable_relaxed_ordering(dev)) {
> +		pcie_clear_relaxed_ordering(dev);
> +		dev_info(&dev->dev, "Disable Relaxed Ordering\n");
> +	}
> +}

I couldn't find anywhere where you actually enable the relaxed ordering
like the subject suggests.

-- 
Sinan Kaya
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm Technologies, Inc.
Qualcomm Technologies, Inc. is a member of the Code Aurora Forum, a Linux Foundation Collaborative Project.
