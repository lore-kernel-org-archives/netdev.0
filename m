From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] CONFIG_PM=n slim: drivers/net/*
Date: Fri, 11 Aug 2006 18:49:43 -0700
Message-ID: <20060811184943.96419537.akpm@osdl.org>
References: <20060812004623.GM6847@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14256 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750872AbWHLBuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2006 21:50:23 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>
In-Reply-To: <20060812004623.GM6847@martell.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 12 Aug 2006 04:46:23 +0400
Alexey Dobriyan <adobriyan@gmail.com> wrote:

> +#ifdef CONFIG_PM
>  static int amd8111e_suspend(struct pci_dev *pci_dev, pm_message_t state)
>  {	
>  	struct net_device *dev = pci_get_drvdata(pci_dev);
> @@ -1873,7 +1879,7 @@ static int amd8111e_resume(struct pci_de
>  
>  	return 0;
>  }
> -
> +#endif
>  
>  static void __devexit amd8111e_remove_one(struct pci_dev *pdev)
>  {
> @@ -2152,8 +2158,10 @@ static struct pci_driver amd8111e_driver
>  	.id_table	= amd8111e_pci_tbl,
>  	.probe		= amd8111e_probe_one,
>  	.remove		= __devexit_p(amd8111e_remove_one),
> +#ifdef CONFIG_PM
>  	.suspend	= amd8111e_suspend,
>  	.resume		= amd8111e_resume
> +#endif
>  };

The preferred way is

#ifdef CONFIG_PM
static int amd8111e_suspend(...)
{
}
#else
#define amd8111e_suspend NULL
#define amd8111e_resume NULL
#endif
