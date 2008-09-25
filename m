From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: Re: [PATCH] net: add net poll support for atl2 driver
Date: Thu, 25 Sep 2008 18:45:09 -0500
Message-ID: <20080925184509.42bfabc2@osprey.hogchain.net>
References: <1221897404-20290-1-git-send-email-kexin.hao@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@redhat.com>, Chris Snook <csnook@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Kevin Hao <kexin.hao@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost05.isp.att.net ([204.127.217.105]:36333 "EHLO
	fmailhost05.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752077AbYIYXpN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 19:45:13 -0400
In-Reply-To: <1221897404-20290-1-git-send-email-kexin.hao@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 20 Sep 2008 15:56:44 +0800
Kevin Hao <kexin.hao@windriver.com> wrote:

> Add netconsole support for Atheros L2 10/100 network device.
> 
> Signed-off-by: Kevin Hao <kexin.hao@windriver.com>
> ---
>  drivers/net/atlx/atl2.c |   12 ++++++++++++
>  1 files changed, 12 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/atlx/atl2.c b/drivers/net/atlx/atl2.c
> index d548a67..b2995ac 100644
> --- a/drivers/net/atlx/atl2.c
> +++ b/drivers/net/atlx/atl2.c
> @@ -1327,6 +1327,15 @@ static void atl2_setup_pcicmd(struct pci_dev
> *pdev) pci_write_config_dword(pdev, REG_PM_CTRLSTAT, 0);
>  }
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void atl2_poll_controller(struct net_device *netdev)
> +{
> +	disable_irq(netdev->irq);
> +	atl2_intr(netdev->irq, netdev);
> +	enable_irq(netdev->irq);
> +}
> +#endif
> +
>  /*
>   * atl2_probe - Device Initialization Routine
>   * @pdev: PCI device information struct
> @@ -1410,6 +1419,9 @@ static int __devinit atl2_probe(struct pci_dev
> *pdev, netdev->do_ioctl = &atl2_ioctl;
>  	atl2_set_ethtool_ops(netdev);
>  
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +	netdev->poll_controller = atl2_poll_controller;
> +#endif
>  #ifdef HAVE_TX_TIMEOUT
>  	netdev->tx_timeout = &atl2_tx_timeout;
>  	netdev->watchdog_timeo = 5 * HZ;

Acked-by: Jay Cliburn <jacliburn@bellsouth.net>
