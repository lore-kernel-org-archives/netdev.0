From: "Jesse Brandeburg" <jesse.brandeburg@gmail.com>
Subject: Re: [PATCH 03/16] 64bit resource: fix up printks for resources in networks drivers
Date: Tue, 13 Jun 2006 09:24:55 -0700
Message-ID: <4807377b0606130924i4b5ea36aq83b8db050831bea4@mail.gmail.com>
References: <20060613003033.GA10717@kroah.com>
	 <11501586781628-git-send-email-greg@kroah.com>
	 <1150158683636-git-send-email-greg@kroah.com>
	 <11501586871870-git-send-email-greg@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	"Greg Kroah-Hartman" <gregkh@suse.de>,
	"NetDEV list" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:55156 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S932176AbWFMQY5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Jun 2006 12:24:57 -0400
Received: by nf-out-0910.google.com with SMTP id n28so185491nfc
        for <netdev@vger.kernel.org>; Tue, 13 Jun 2006 09:24:56 -0700 (PDT)
To: "Greg KH" <greg@kroah.com>
In-Reply-To: <11501586871870-git-send-email-greg@kroah.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

First, added netdev,

On 6/12/06, Greg KH <greg@kroah.com> wrote:
> From: Greg Kroah-Hartman <gregkh@suse.de>
>
> This is needed if we wish to change the size of the resource structures.
>
> Based on an original patch from Vivek Goyal <vgoyal@in.ibm.com>
>
> Cc: Vivek Goyal <vgoyal@in.ibm.com>
> Cc: Andrew Morton <akpm@osdl.org>
> Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>
> ---
>  drivers/net/3c59x.c            |    6 ++++--
>  drivers/net/8139cp.c           |    9 +++++----
>  drivers/net/8139too.c          |    6 +++---
>  drivers/net/e100.c             |    4 ++--
>  drivers/net/skge.c             |    4 ++--
>  drivers/net/sky2.c             |    6 +++---
>  drivers/net/tulip/de2104x.c    |    9 +++++----
>  drivers/net/tulip/tulip_core.c |    6 +++---
>  drivers/net/typhoon.c          |    5 +++--
>  drivers/net/wan/dscc4.c        |   12 ++++++------
>  drivers/net/wan/pc300_drv.c    |    4 ++--
>  11 files changed, 38 insertions(+), 33 deletions(-)
>
> diff --git a/drivers/net/e100.c b/drivers/net/e100.c
> index 31ac001..0c0bd67 100644
> --- a/drivers/net/e100.c
> +++ b/drivers/net/e100.c
> @@ -2678,9 +2678,9 @@ #endif
>                 goto err_out_free;
>         }
>
> -       DPRINTK(PROBE, INFO, "addr 0x%lx, irq %d, "
> +       DPRINTK(PROBE, INFO, "addr 0x%llx, irq %d, "
>                 "MAC addr %02X:%02X:%02X:%02X:%02X:%02X\n",
> -               pci_resource_start(pdev, 0), pdev->irq,
> +               (unsigned long long)pci_resource_start(pdev, 0), pdev->irq,
>                 netdev->dev_addr[0], netdev->dev_addr[1], netdev->dev_addr[2],
>                 netdev->dev_addr[3], netdev->dev_addr[4], netdev->dev_addr[5]);

color me confused, but why is this change necessary for e100?  e100
can not support 64 bit BARs, so it seems to me to make little sense to
cast to unsigned long long.  e100 is 32 bit the whole way through.

Jesse
