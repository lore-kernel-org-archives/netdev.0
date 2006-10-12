From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] sk98lin: handle pci_enable_device() return value in
 skge_resume() properly
Date: Thu, 12 Oct 2006 15:25:12 -0700
Message-ID: <20061012152512.66f147b8@freekitty>
References: <Pine.LNX.4.64.0610130002320.29022@twin.jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mlindner@syskonnect.de, rroesler@syskonnect.de,
	Andrew Morton <akpm@osdl.org>, Jeff Garzik <jeff@garzik.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:59089 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1751219AbWJLW2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 18:28:08 -0400
To: Jiri Kosina <jikos@jikos.cz>
In-Reply-To: <Pine.LNX.4.64.0610130002320.29022@twin.jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 13 Oct 2006 00:17:50 +0200 (CEST)
Jiri Kosina <jikos@jikos.cz> wrote:

> [PATCH] sk98lin: handle pci_enable_device() return value in skge_resume() properly
> 
> Fix missing handling of pci_enable_device() return value in skge_resume() 
> 
> Signed-off-by: Jiri Kosina <jikos@jikos.cz>
> 
> --- 
> 
>  drivers/net/sk98lin/skge.c |    6 +++++-
>  1 files changed, 5 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/sk98lin/skge.c b/drivers/net/sk98lin/skge.c
> index 99e9262..e12fb62 100644
> --- a/drivers/net/sk98lin/skge.c
> +++ b/drivers/net/sk98lin/skge.c
> @@ -5070,7 +5070,11 @@ static int skge_resume(struct pci_dev *p
>  
>  	pci_set_power_state(pdev, PCI_D0);
>  	pci_restore_state(pdev);
> -	pci_enable_device(pdev);
> +	if ((ret = pci_enable_device(pdev))) {
> +		printk(KERN_ERR "sk98lin: Cannot enable PCI device during resume\n");
> +		unregister_netdev(dev);
>

Having the device unregister seems harsh.
Why put condtional on same line?
Why not print device name dev->name.


-- 
Stephen Hemminger <shemminger@osdl.org>
