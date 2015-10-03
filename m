From: Mauro Carvalho Chehab <mchehab@osg.samsung.com>
Subject: Re: [PATCH 05/15] cx88: use pci_set_dma_mask insted of
 pci_dma_supported
Date: Sat, 3 Oct 2015 13:58:16 -0300
Message-ID: <20151003135816.23cb243f@recife.lan>
References: <1443885579-7094-1-git-send-email-hch@lst.de>
	<1443885579-7094-6-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Don Fry <pcnet32@frontier.com>,
	Oliver Neukum <oneukum@suse.com>,
	linux-net-drivers@solarflare.com, dri-devel@lists.freedesktop.org,
	linux-media@vger.kernel.org, netdev@vger.kernel.org,
	linux-parisc@vger.kernel.org, linux-serial@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lists.s-osg.org ([54.187.51.154]:47217 "EHLO lists.s-osg.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779AbbJCQ6Z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 3 Oct 2015 12:58:25 -0400
In-Reply-To: <1443885579-7094-6-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christoph,


Em Sat,  3 Oct 2015 17:19:29 +0200
Christoph Hellwig <hch@lst.de> escreveu:

> This ensures the dma mask that is supported by the driver is recorded
> in the device structure.


For this and the other patches touching at drivers/media:

Acked-by: Mauro Carvalho Chehab <mchehab@osg.samsung.com>

> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  drivers/media/pci/cx88/cx88-alsa.c  | 2 +-
>  drivers/media/pci/cx88/cx88-mpeg.c  | 2 +-
>  drivers/media/pci/cx88/cx88-video.c | 2 +-
>  3 files changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/media/pci/cx88/cx88-alsa.c b/drivers/media/pci/cx88/cx88-alsa.c
> index 7f8dc60..0703a81 100644
> --- a/drivers/media/pci/cx88/cx88-alsa.c
> +++ b/drivers/media/pci/cx88/cx88-alsa.c
> @@ -890,7 +890,7 @@ static int snd_cx88_create(struct snd_card *card, struct pci_dev *pci,
>  		return err;
>  	}
>  
> -	if (!pci_dma_supported(pci,DMA_BIT_MASK(32))) {
> +	if (!pci_set_dma_mask(pci,DMA_BIT_MASK(32))) {
>  		dprintk(0, "%s/1: Oops: no 32bit PCI DMA ???\n",core->name);
>  		err = -EIO;
>  		cx88_core_put(core, pci);
> diff --git a/drivers/media/pci/cx88/cx88-mpeg.c b/drivers/media/pci/cx88/cx88-mpeg.c
> index 34f5057..9b3b565 100644
> --- a/drivers/media/pci/cx88/cx88-mpeg.c
> +++ b/drivers/media/pci/cx88/cx88-mpeg.c
> @@ -393,7 +393,7 @@ static int cx8802_init_common(struct cx8802_dev *dev)
>  	if (pci_enable_device(dev->pci))
>  		return -EIO;
>  	pci_set_master(dev->pci);
> -	if (!pci_dma_supported(dev->pci,DMA_BIT_MASK(32))) {
> +	if (!pci_set_dma_mask(dev->pci,DMA_BIT_MASK(32))) {
>  		printk("%s/2: Oops: no 32bit PCI DMA ???\n",dev->core->name);
>  		return -EIO;
>  	}
> diff --git a/drivers/media/pci/cx88/cx88-video.c b/drivers/media/pci/cx88/cx88-video.c
> index 400e5ca..f12af31 100644
> --- a/drivers/media/pci/cx88/cx88-video.c
> +++ b/drivers/media/pci/cx88/cx88-video.c
> @@ -1311,7 +1311,7 @@ static int cx8800_initdev(struct pci_dev *pci_dev,
>  	       dev->pci_lat,(unsigned long long)pci_resource_start(pci_dev,0));
>  
>  	pci_set_master(pci_dev);
> -	if (!pci_dma_supported(pci_dev,DMA_BIT_MASK(32))) {
> +	if (!pci_set_dma_mask(pci_dev,DMA_BIT_MASK(32))) {
>  		printk("%s/0: Oops: no 32bit PCI DMA ???\n",core->name);
>  		err = -EIO;
>  		goto fail_core;
