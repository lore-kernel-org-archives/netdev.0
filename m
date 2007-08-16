From: Tejun Heo <teheo@suse.de>
Subject: Re: [patch 4/4] Update e1000 driver to use devres.
Date: Thu, 16 Aug 2007 20:44:17 +0900
Message-ID: <46C43891.4080304@suse.de>
References: <20070815190014.GE7294@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Brandon Philips <bphilips@suse.de>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20070815190014.GE7294@ifup.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Brandon Philips wrote:
> -	mmio_start = pci_resource_start(pdev, BAR_0);
>  	mmio_len = pci_resource_len(pdev, BAR_0);

You don't need mmio_len either.

> -	err = -EIO;
> -	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
> +	adapter->hw.hw_addr = pcim_iomap(pdev, BAR_0, mmio_len);

Passing 0 as @max_len tells pci[m]_iomap() to use pci_resource_len() of
the BAR.

> @@ -952,16 +948,15 @@ e1000_probe(struct pci_dev *pdev,
>  	/* setup the private structure */
>  
>  	if ((err = e1000_sw_init(adapter)))
> -		goto err_sw_init;
> +		return err;
>  
>  	err = -EIO;
>  	/* Flash BAR mapping must happen after e1000_sw_init
>  	 * because it depends on mac_type */
>  	if ((adapter->hw.mac_type == e1000_ich8lan) &&
>  	   (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
> -		flash_start = pci_resource_start(pdev, 1);
>  		flash_len = pci_resource_len(pdev, 1);

Ditto.

> -		adapter->hw.flash_address = ioremap(flash_start, flash_len);
> +		adapter->hw.flash_address = pcim_iomap(pdev, 1, flash_len);
>  		if (!adapter->hw.flash_address)
>  			goto err_flashmap;
>  	}

-- 
tejun

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
