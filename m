From: Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>
Subject: Re: [PATCH] ide/net: flip the order of SATA and network init
Date: Wed, 28 Jan 2009 01:22:20 +0100
Message-ID: <200901280122.24499.bzolnier@gmail.com>
References: <20090127141952.51785b4f@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-ide@vger.kernel.org, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <linux-ide-owner@vger.kernel.org>
In-Reply-To: <20090127141952.51785b4f@infradead.org>
Content-Disposition: inline
Sender: linux-ide-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 27 January 2009, Arjan van de Ven wrote:
> From e89d6840ad685a3c61f72367d4ac5bfed69ead0c Mon Sep 17 00:00:00 2001
> From: Arjan van de Ven <arjan@linux.intel.com>
> Date: Mon, 26 Jan 2009 18:58:11 -0800
> Subject: [PATCH] ide/net: flip the order of SATA and network init
> 
> this patch flips the order in which sata and network drivers are initialized.

it seems to affect much more than that, please see below

> SATA probing takes quite a bit of time, and with the asynchronous infrastructure
> other drivers that run after it can execute in parallel. Network drivers do tend
> to take some real time talking to the hardware, so running these later is
> a good thing (the sata probe then runs concurrent)
> 
> This saves about 15% of my kernels boot time.
> 
> Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
> ---
>  drivers/Makefile |    5 +++--
>  1 files changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/Makefile b/drivers/Makefile
> index c1bf417..2618a61 100644
> --- a/drivers/Makefile
> +++ b/drivers/Makefile
> @@ -36,13 +36,14 @@ obj-$(CONFIG_FB_INTEL)          += video/intelfb/
>  
>  obj-y				+= serial/
>  obj-$(CONFIG_PARPORT)		+= parport/
> -obj-y				+= base/ block/ misc/ mfd/ net/ media/
> +obj-y				+= base/ block/ misc/ mfd/ media/
>  obj-$(CONFIG_NUBUS)		+= nubus/
> -obj-$(CONFIG_ATM)		+= atm/
>  obj-y				+= macintosh/
>  obj-$(CONFIG_IDE)		+= ide/
>  obj-$(CONFIG_SCSI)		+= scsi/

scsi, ide, macintosh and nubus will be now init-ed after network.

No problem for ide but I'm not really sure about scsi...

>  obj-$(CONFIG_ATA)		+= ata/
> +obj-y				+= net/
> +obj-$(CONFIG_ATM)		+= atm/
>  obj-$(CONFIG_FUSION)		+= message/
>  obj-$(CONFIG_FIREWIRE)		+= firewire/
>  obj-y				+= ieee1394/
