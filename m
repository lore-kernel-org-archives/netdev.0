From: Stanislaw Gruszka <sgruszka@redhat.com>
Subject: Re: Subject: [PATCH 2/6] bna: Brocade 10Gb Ethernet device driver
Date: Mon, 22 Feb 2010 13:36:30 +0100
Message-ID: <20100222123629.GC2520@dhcp-lab-161.englab.brq.redhat.com>
References: <201002192152.o1JLqcI5031959@blc-10-1.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, adapter_linux_open_src_team@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11665 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752105Ab0BVMiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Feb 2010 07:38:25 -0500
Content-Disposition: inline
In-Reply-To: <201002192152.o1JLqcI5031959@blc-10-1.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 19, 2010 at 01:52:38PM -0800, Rasesh Mody wrote:
> From: Rasesh Mody <rmody@brocade.com>
> 
> This is patch 2/6 which contains linux driver source for
> Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
> Source is based against net-next-2.6.
> 
> We wish this patch to be considered for inclusion in net-next-2.6
> 
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>  bfad_fwimg.c   |   94 ++
>  bna_fn.c       | 1795 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  bna_queue.c    |  394 ++++++++++++
>  bnad_ethtool.c | 1100 ++++++++++++++++++++++++++++++++++
>  4 files changed, 3383 insertions(+)
[snip]

> +u32 *
> +bfad_read_firmware(struct pci_dev *pdev, u32 **bfi_image,
> +			u32 *bfi_image_size, char *fw_name)
> +{
> +	const struct firmware *fw;
> +
> +	if (request_firmware(&fw, fw_name, &pdev->dev)) {
> +		printk(KERN_ALERT "Can't locate firmware %s\n", fw_name);
> +		goto error;
> +	}
> +
> +	*bfi_image = vmalloc(fw->size);
> +	if (NULL == *bfi_image) {
> +		printk(KERN_ALERT "Fail to allocate buffer for fw image "
> +			"size=%x!\n", (u32) fw->size);
> +		goto error;
> +	}
> +
> +	memcpy(*bfi_image, fw->data, fw->size);

Why do you alloc and copy image, why not just use fw->data?

> +	 struct bfa_log_mod *logmod)
> +{
> +	u32 pcifn;
> +
> +	memset(dev, 0, sizeof(struct bna_dev));
> +
> +	dev->trcmod = trcmod;
> +	dev->logmod = logmod;
> +
> +	dev->bar0 = (u8 *) bar0;
> +	dev->hw_stats = (struct bfi_ll_stats *)stats;
> +	dev->hw_stats_dma.msb = stats_dma.msb;
> +	dev->hw_stats_dma.lsb = stats_dma.lsb;
> +
> +	dev->rxf_promiscuous_id = BNA_RXF_ID_NONE;
> +	dev->rxf_default_id = BNA_RXF_ID_NONE;
> +
> +	pcifn = readl(dev->bar0 + FNC_ID_REG);
> +	pcifn = readl(dev->bar0 + FNC_ID_REG);
What for you read this twice?

> +	/* we always use RSS table 0 */
> +	writel(cfg_ptr->flags & BNA_RXF_CF_RSS_ENABLE,
> +		&rx_fndb_ram[rxf_id].rss_prop);
> +
> +	/* small large buffer enable/disable */
> +	writel((cfg_ptr->flags & BNA_RXF_CF_SM_LG_RXQ) | 0x80,
> +		&rx_fndb_ram[rxf_id].size_routing_props);
> +
> +	/* RIT offset, HDS forced offset, multicast RxQ Id */
> +	writel(
> +		       (cfg_ptr->rit_offset << 16) | (cfg_ptr->hds.
> +						      forced_offset << 8) |
> +		       (cfg_ptr->hds.type & BNA_HDS_FORCED) | cfg_ptr->
> +		       mcast_rxq_id, &rx_fndb_ram[rxf_id].rit_hds_mcastq);
Please use normal indentions.

