From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: [PATCH] use dev_printk() in some net drivers
Date: Tue, 27 Jun 2006 17:10:23 +0200
Message-ID: <44A14A5F.3090607@gmail.com>
References: <20060627145145.GA30053@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.190]:65229 "EHLO
	nf-out-0910.google.com") by vger.kernel.org with ESMTP
	id S1161085AbWF0PJN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Jun 2006 11:09:13 -0400
Received: by nf-out-0910.google.com with SMTP id m19so743189nfc
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2006 08:09:12 -0700 (PDT)
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <20060627145145.GA30053@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik napsal(a):
> commit 25a0324ef1c1b181c9d00f09837e8757875ee2a4
> Author: Jeff Garzik <jeff@garzik.org>
> Date:   Tue Jun 27 10:47:51 2006 -0400
> 
>     [netdrvr] Use dev_printk() when ethernet interface isn't available
> 
>     For messages prior to register_netdev(), prefer dev_printk() because
>     that prints out both our driver name and our [PCI | whatever] bus id.
> 
>     Updates: 8139{cp,too}, b44, bnx2, cassini, {eepro,epic}100, fealnx,
>          hamachi, ne2k-pci, ns83820, pci-skeleton, r8169.
> 
>     Signed-off-by: Jeff Garzik <jeff@garzik.org>
> 
>  drivers/net/8139cp.c       |   36 +++++++++++++++++++++---------------
>  drivers/net/8139too.c      |   41 +++++++++++++++++++++++++----------------
>  drivers/net/b44.c          |   28 +++++++++++++++-------------
>  drivers/net/bnx2.c         |   37 ++++++++++++++++++++++---------------
>  drivers/net/cassini.c      |   20 ++++++++++----------
>  drivers/net/eepro100.c     |    8 +++++---
>  drivers/net/epic100.c      |   23 ++++++++++++-----------
>  drivers/net/fealnx.c       |   17 +++++++++--------
>  drivers/net/hamachi.c      |    3 ++-
>  drivers/net/ne2k-pci.c     |   12 ++++++++----
>  drivers/net/ns83820.c      |   14 +++++++++-----
>  drivers/net/pci-skeleton.c |   24 +++++++++++++++---------
>  drivers/net/r8169.c        |   43 +++++++++++++++++++------------------------
>  13 files changed, 172 insertions(+), 134 deletions(-)
> 
> 25a0324ef1c1b181c9d00f09837e8757875ee2a4
> diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
> index 0cdc830..c38e352 100644
> --- a/drivers/net/8139cp.c
> +++ b/drivers/net/8139cp.c
> @@ -1837,9 +1837,11 @@ #endif
>  
>  	if (pdev->vendor == PCI_VENDOR_ID_REALTEK &&
>  	    pdev->device == PCI_DEVICE_ID_REALTEK_8139 && pci_rev < 0x20) {
> -		printk(KERN_ERR PFX "pci dev %s (id %04x:%04x rev %02x) is not an 8139C+ compatible chip\n",
> -		       pci_name(pdev), pdev->vendor, pdev->device, pci_rev);
> -		printk(KERN_ERR PFX "Try the \"8139too\" driver instead.\n");
> +		dev_printk(KERN_ERR, &pdev->dev,
> +			   "This (id %04x:%04x rev %02x) is not an 8139C+ compatible chip\n",
> +		           pdev->vendor, pdev->device, pci_rev);
> +		dev_printk(KERN_ERR, &pdev->dev,
> +			   "Try the \"8139too\" driver instead.\n");
>  		return -ENODEV;
>  	}
>  

Don't you consider to use s#dev_printk(KERN_ERR, #dev_err(# macro?

regards,
-- 
Jiri Slaby         www.fi.muni.cz/~xslaby
~\-/~      jirislaby@gmail.com      ~\-/~
B67499670407CE62ACC8 22A032CC55C339D47A7E
