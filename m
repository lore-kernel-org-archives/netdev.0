From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Subject: Re: [PATCH V3 net-next 02/14] net/ena: fix error handling when probe
 fails
Date: Sat, 28 Jan 2017 00:33:33 +0100
Message-ID: <174cba24-4bf4-4212-9756-2bedf4fa5a92@gmx.de>
References: <1485469096-5271-1-git-send-email-netanel@annapurnalabs.com>
 <1485469096-5271-3-git-send-email-netanel@annapurnalabs.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dwmw@amazon.com, zorik@annapurnalabs.com, alex@annapurnalabs.com,
        saeed@annapurnalabs.com, msw@amazon.com, aliguori@amazon.com,
        nafea@annapurnalabs.com, eric.dumazet@gmail.com
To: Netanel Belgazal <netanel@annapurnalabs.com>,
        linux-kernel@vger.kernel.org, davem@davemloft.net,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:52048 "EHLO mout.gmx.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750720AbdA0Xdu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Jan 2017 18:33:50 -0500
In-Reply-To: <1485469096-5271-3-git-send-email-netanel@annapurnalabs.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 26.01.2017 23:18, Netanel Belgazal wrote:
> When driver fails in probe, it will release all resources,
> including adapter.
> In case of probe failure, ena_remove should not try to
> free the adapter resources.
>
> Signed-off-by: Netanel Belgazal <netanel@annapurnalabs.com>
> ---
>  drivers/net/ethernet/amazon/ena/ena_netdev.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/drivers/net/ethernet/amazon/ena/ena_netdev.c b/drivers/net/ethernet/amazon/ena/ena_netdev.c
> index 7493ea3..cb60567 100644
> --- a/drivers/net/ethernet/amazon/ena/ena_netdev.c
> +++ b/drivers/net/ethernet/amazon/ena/ena_netdev.c
> @@ -3046,6 +3046,7 @@ static int ena_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
>  err_free_region:
>  	ena_release_bars(ena_dev, pdev);
>  err_free_ena_dev:
> +	pci_set_drvdata(pdev, NULL);
>  	vfree(ena_dev);
>  err_disable_device:
>  	pci_disable_device(pdev);
>

Is this change really a "fix"? remove() should only be called if
probe() has been successful before, otherwise not. Did you experience
something different?

Regards,
Lino
