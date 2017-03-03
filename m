From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] net: thunderx: Fix IOMMU translation faults
Date: Fri, 03 Mar 2017 09:56:35 -0800 (PST)
Message-ID: <20170303.095635.355325147613813698.davem@davemloft.net>
References: <1488538070-12549-1-git-send-email-sunil.kovvuri@gmail.com>
        <1488538070-12549-2-git-send-email-sunil.kovvuri@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org, sgoutham@cavium.com
To: sunil.kovvuri@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1488538070-12549-2-git-send-email-sunil.kovvuri@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: sunil.kovvuri@gmail.com
Date: Fri,  3 Mar 2017 16:17:47 +0530

> @@ -1643,6 +1650,9 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	if (!pass1_silicon(nic->pdev))
>  		nic->hw_tso = true;
>  
> +	/* Check if we are attached to IOMMU */
> +	nic->iommu_domain = iommu_get_domain_for_dev(dev);

This function is not universally available.

This looks very hackish to me anyways, how all of this stuff is supposed
to work is that you simply use the DMA interfaces unconditionally and
whatever is behind the operations takes care of everything.

Doing it conditionally in the driver with all of this special IOMMU
domain et al. knowledge makes no sense to me at all.

I don't see other drivers doing stuff like this at all, so if you're
going to handle this in a unique way like this you better write
several paragraphs in your commit message explaining why this weird
crap is necessary.

There is no way I can apply this series as it is current written.

Thanks.
