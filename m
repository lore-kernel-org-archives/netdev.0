From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 1/8] i40evf: main driver core
Date: Wed, 8 Jan 2014 14:20:32 +0000
Message-ID: <1389190832.2728.60.camel@deadeye.wl.decadent.org.uk>
References: <1388537594-24601-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1388537594-24601-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Greg Rose <gregory.v.rose@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>,
	"Mitch Williams" <mitch.a.williams@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:18508 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756013AbaAHOUf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:20:35 -0500
In-Reply-To: <1388537594-24601-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-12-31 at 16:53 -0800, Jeff Kirsher wrote:
[...]
> +static int i40evf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> +{
> +	struct net_device *netdev;
> +	struct i40evf_adapter *adapter = NULL;
> +	struct i40e_hw *hw = NULL;
> +	int err, pci_using_dac;
> +
> +	err = pci_enable_device(pdev);
> +	if (err)
> +		return err;
> +
> +	if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(64))) {
> +		pci_using_dac = true;
> +		/* coherent mask for the same size will always succeed if
> +		 * dma_set_mask does
> +		 */
> +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(64));
> +	} else if (!dma_set_mask(&pdev->dev, DMA_BIT_MASK(32))) {
> +		pci_using_dac = false;
> +		dma_set_coherent_mask(&pdev->dev, DMA_BIT_MASK(32));
> +	} else {
> +		dev_err(&pdev->dev, "%s: DMA configuration failed: %d\n",
> +			 __func__, err);
> +		err = -EIO;
> +		goto err_dma;
> +	}
[...]

Should use dma_set_mask_and_coherent().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
