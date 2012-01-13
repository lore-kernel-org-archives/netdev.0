From: "Arend van Spriel" <arend@broadcom.com>
Subject: Re: [PATCH 1/5] bcma: convert suspend/resume to pm_ops
Date: Fri, 13 Jan 2012 10:58:35 +0100
Message-ID: <4F10004B.5010309@broadcom.com>
References: <CA+55aFzm21ZKs7e_ocVA1bQQ=Js2dJpbiycwHR3v8yNvb0MgTw@mail.gmail.com>
 <1326440480-26271-1-git-send-email-zajec5@gmail.com>
 <alpine.LNX.2.00.1201122354430.5860@air.linux-foundation.org>
 <alpine.LNX.2.00.1201122359400.5860@air.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-2?Q?Rafa=B3_Mi=B3ecki?= <zajec5@gmail.com>,
	"Larry Finger" <Larry.Finger@lwfinger.net>,
	"Alwin Beukers" <alwin@broadcom.com>,
	"Roland Vossen" <rvossen@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Network Development" <netdev@vger.kernel.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>
To: "Linus Torvalds" <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2727 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627Ab2AMJ6v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jan 2012 04:58:51 -0500
In-Reply-To: <alpine.LNX.2.00.1201122359400.5860@air.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2012 09:00 AM, Linus Torvalds wrote:
> 
> From: Linus Torvalds <torvalds@linux-foundation.org>
> Date: Thu, 12 Jan 2012 22:47:01 -0800
> 
> .. and avoid doing th eunnecessary PCI operations - the PCI layer will do them for us.
> 
> Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> ---
>  drivers/bcma/host_pci.c |   38 +++++++++++++-------------------------
>  1 files changed, 13 insertions(+), 25 deletions(-)
> 
> diff --git a/drivers/bcma/host_pci.c b/drivers/bcma/host_pci.c
> index 443b83a2fd7a..3aee641c9b7b 100644
> --- a/drivers/bcma/host_pci.c
> +++ b/drivers/bcma/host_pci.c
> @@ -235,38 +235,27 @@ static void bcma_host_pci_remove(struct pci_dev *dev)
>  }
>  
>  #ifdef CONFIG_PM
> -static int bcma_host_pci_suspend(struct pci_dev *dev, pm_message_t state)
> +static int bcma_suspend(struct device *dev)

All functions in host_pci.c start with bcma_host_pci_ prefix. Can we
stick to that convention?

>  {
> -	/* Host specific */
> -	pci_save_state(dev);
> -	pci_disable_device(dev);
> -	pci_set_power_state(dev, pci_choose_state(dev, state));
> -
>  	return 0;
>  }
>  
> -static int bcma_host_pci_resume(struct pci_dev *dev)
> +static int bcma_resume(struct device *dev)

Same here. It does not refer to the type of the device parameter.

Gr. AvS
