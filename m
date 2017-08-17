From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH net RESEND] PCI: fix oops when try to find Root Port for a PCI device
Date: Thu, 17 Aug 2017 15:12:58 +1000
Message-ID: <87fucqsrol.fsf@concordia.ellerman.id.au>
References: <1502810688-12420-1-git-send-email-dingtianhong@huawei.com> <20170815170331.GA4099@bhelgaas-glaptop.roam.corp.google.com> <20170816193303.GA14147@ulmo>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Ding Tianhong <dingtianhong@huawei.com>, mark.rutland@arm.com,
        gabriele.paoloni@huawei.com, asit.k.mallick@intel.com,
        catalin.marinas@arm.com, will.deacon@arm.com, linuxarm@huawei.com,
        alexander.duyck@gmail.com, ashok.raj@intel.com,
        eric.dumazet@gmail.com, jeffrey.t.kirsher@intel.com,
        linux-pci@vger.kernel.org, ganeshgr@chelsio.com, Bob.Shaw@amd.com,
        leedom@chelsio.com, patrick.j.cramer@intel.com,
        bhelgaas@google.com, werner@chelsio.com,
        linux-arm-kernel@lists.infradead.org, amira@mellanox.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        David.Laight@aculab.com, Suravee.Suthikulpanit@amd.com,
        robin.murphy@arm.com, davem@davemloft.net, l.stach@pengutronix.de
To: Thierry Reding <thierry.reding@gmail.com>,
        Bjorn Helgaas <helgaas@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170816193303.GA14147@ulmo>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thierry Reding <thierry.reding@gmail.com> writes:
...
>
> In case of Tegra, dev actually points to the root port. Now if I read
> the above code correctly, highest_pcie_bridge will still be NULL in that
> case, which in turn will return NULL from pci_find_pcie_root_port(). But
> shouldn't it really return dev?
>
> The patch that I used to fix the issue is this:
>
> --->8---
> diff --git a/drivers/pci/pci.c b/drivers/pci/pci.c
> index 2c712dcfd37d..dd56c1c05614 100644
> --- a/drivers/pci/pci.c
> +++ b/drivers/pci/pci.c
> @@ -514,7 +514,7 @@ EXPORT_SYMBOL(pci_find_resource);
>   */
>  struct pci_dev *pci_find_pcie_root_port(struct pci_dev *dev)
>  {
> -       struct pci_dev *bridge, *highest_pcie_bridge = NULL;
> +       struct pci_dev *bridge, *highest_pcie_bridge = dev;
>  
>         bridge = pci_upstream_bridge(dev);
>         while (bridge && pci_is_pcie(bridge)) {
> --->8---
>
> That works correctly if this function ends up being called on the PCIe
> root port, though perhaps that's not what this function is supposed to
> do. It's somewhat unclear from the kerneldoc what the function should
> be doing when called on a root port device itself.

That also works for me on powerpc (oops reported up thread).

cheers
