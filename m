From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [2.6 patch] drivers/net/s2io.c section fixes
Date: Tue, 11 Dec 2007 18:16:51 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD7702B13B2D@nekter>
References: <20071211222306.GV14204@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	"Rastapur Santosh" <santosh.rastapur@neterion.com>,
	"Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>,
	"Sreenivasa Honnur" <Sreenivasa.Honnur@neterion.com>
To: "Adrian Bunk" <bunk@kernel.org>, <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:59528 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755827AbXLKXR1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 18:17:27 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071211222306.GV14204@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks. Patch looks good. Please accept.

Ram

> -----Original Message-----
> From: Adrian Bunk [mailto:bunk@kernel.org]
> Sent: Tuesday, December 11, 2007 2:23 PM
> To: ram.vepa@neterion.com; Rastapur Santosh; Sivakumar Subramani;
> Sreenivasa Honnur; jgarzik@pobox.com
> Cc: netdev@vger.kernel.org; linux-kernel@vger.kernel.org
> Subject: [2.6 patch] drivers/net/s2io.c section fixes
> 
> Code used by the non-__devinit s2io_open() mustn't be __devinit.
> 
> This patch fixes the following section mismatch with CONFIG_HOTPLUG=n:
> 
> <--  snip  -->
> 
> ...
> WARNING: vmlinux.o(.text+0x6f6e3e): Section mismatch: reference to
> .init.text.20:s2io_test_intr (between 's2io_open' and
's2io_ethtool_sset')
> ...
> 
> <--  snip  -->
> 
> Signed-off-by: Adrian Bunk <bunk@kernel.org>
> 
> ---
> 
>  drivers/net/s2io.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> 50fb761b99d7ee0b234359d02144f84a87e2faff
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 121cb10..9d80f1c 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -3737,7 +3737,7 @@ static int s2io_enable_msi_x(struct s2io_nic
*nic)
>  }
> 
>  /* Handle software interrupt used during MSI(X) test */
> -static irqreturn_t __devinit s2io_test_intr(int irq, void *dev_id)
> +static irqreturn_t s2io_test_intr(int irq, void *dev_id)
>  {
>  	struct s2io_nic *sp = dev_id;
> 
> @@ -3748,7 +3748,7 @@ static irqreturn_t __devinit s2io_test_intr(int
irq,
> void *dev_id)
>  }
> 
>  /* Test interrupt path by forcing a a software IRQ */
> -static int __devinit s2io_test_msi(struct s2io_nic *sp)
> +static int s2io_test_msi(struct s2io_nic *sp)
>  {
>  	struct pci_dev *pdev = sp->pdev;
>  	struct XENA_dev_config __iomem *bar0 = sp->bar0;
