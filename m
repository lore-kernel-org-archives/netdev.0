From: "Eliezer Tamir" <eliezer.tamir@gmail.com>
Subject: Re: [PATCH] pci: use pci_ioremap_bar() in drivers/net
Date: Wed, 22 Oct 2008 09:05:20 +0200
Message-ID: <a15869500810220005h76149fd1w5d325ff18659fa74@mail.gmail.com>
References: <20081020214239.398f1838@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Arjan van de Ven" <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:21968 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753920AbYJVHFW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 03:05:22 -0400
Received: by ey-out-2122.google.com with SMTP id 6so910973eyi.37
        for <netdev@vger.kernel.org>; Wed, 22 Oct 2008 00:05:20 -0700 (PDT)
In-Reply-To: <20081020214239.398f1838@infradead.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BNX2X devices have two BARs.
You might want to convert both.

Cheers,
Eliezer

On Tue, Oct 21, 2008 at 6:42 AM, Arjan van de Ven <arjan@infradead.org> wrote:
> Now that Linus added the pci_ioremap_bar() helper macro, this can go through
>
>
> From: Arjan van de Ven <arjan@linux.intel.com>
> Date: Sun, 28 Sep 2008 16:17:08 -0700
> Subject: [PATCH] pci: use pci_ioremap_bar() in drivers/net
>
> Use the newly introduced pci_ioremap_bar() function in drivers/net.
> pci_ioremap_bar() just takes a pci device and a bar number, with the goal
> of making it really hard to get wrong, while also having a central place
> to stick sanity checks.
>
> CC: netdev@vger.kernel.org
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
>  drivers/net/bnx2x_main.c                 |    3 +--

...
>
> diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
> index fce7451..8f7c3e9 100644
> --- a/drivers/net/bnx2x_main.c
> +++ b/drivers/net/bnx2x_main.c
> @@ -10090,8 +10090,7 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
>
>        dev->irq = pdev->irq;
>
> -       bp->regview = ioremap_nocache(dev->base_addr,
> -                                     pci_resource_len(pdev, 0));
> +       bp->regview = pci_ioremap_bar(pdev, 0);
>        if (!bp->regview) {
>                printk(KERN_ERR PFX "Cannot map register space, aborting\n");
>                rc = -ENOMEM;
