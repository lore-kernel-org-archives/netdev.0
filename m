From: Matt Wilson <msw@amzn.com>
Subject: Re: [PATCH V2 net 02/20] net/ena: fix error handling when probe fails
Date: Sun, 4 Dec 2016 20:09:55 -0800
Message-ID: <20161205040955.GC4310@u54ee753d2d1854bda401.ant.amazon.com>
References: <1480857578-5065-1-git-send-email-netanel@annapurnalabs.com>
 <1480857578-5065-3-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
        <netdev@vger.kernel.org>, <dwmw@amazon.com>,
        <zorik@annapurnalabs.com>, <alex@annapurnalabs.com>,
        <saeed@annapurnalabs.com>, <msw@amazon.com>, <aliguori@amazon.com>,
        <nafea@annapurnalabs.com>
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-fw-33001.amazon.com ([207.171.189.228]:44863 "EHLO
        smtp-fw-33001.amazon.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751736AbcLEEKi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 23:10:38 -0500
Content-Disposition: inline
In-Reply-To: <1480857578-5065-3-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 04, 2016 at 03:19:20PM +0200, Netanel Belgazal wrote:
> When driver fails in probe, it will release all resources, including
> adapter.
> In case of probe failure, ena_remove should not try to free the adapter
> resources.

Please word wrap your commit message around 75 columns.

> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>

Reviewed-by: Matt Wilson <msw@amazon.com>

> ---
>  drivers/net/ethernet/amazon/ena/ena_netdev.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
> index 33a760e..397c9bc 100644
> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
> @@ -3054,6 +3054,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  err_free_region:
>  	ena_release_bars(ena_dev, pdev);
>  err_free_ena_dev:
> +	pci_set_drvdata(pdev, NULL);
>  	vfree(ena_dev);
>  err_disable_device:
>  	pci_disable_device(pdev);
