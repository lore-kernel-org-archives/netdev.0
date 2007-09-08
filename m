From: Luca <kronos.it@gmail.com>
Subject: Re: [atl1-devel] [PATCH 2/2] atl1: wrap problematic optimizations in CONFIG_ATL1_EXPERIMENTAL
Date: Sat, 8 Sep 2007 02:21:24 +0200
Message-ID: <68676e00709071721g35c07b0by58991c56e17ec442@mail.gmail.com>
References: <46E1E1AC.5030801@redhat.com>
	 <20070907235209.GB12055@shell.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>, atl1-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: "Chris Snook" <csnook@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:32589 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbXIHAV2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2007 20:21:28 -0400
Received: by wa-out-1112.google.com with SMTP id v27so711518wah
        for <netdev@vger.kernel.org>; Fri, 07 Sep 2007 17:21:28 -0700 (PDT)
In-Reply-To: <20070907235209.GB12055@shell.boston.redhat.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/8/07, Chris Snook <csnook@redhat.com> wrote:
> From: Chris Snook <csnook@redhat.com>
>
> Make certain problematic optimizations build-time configurable.
>
> Signed-off-by: Chris Snook <csnook@redhat.com>
> Acked-by: Jay Cliburn <jacliburn@bellsouth.net>
>
> --- a/drivers/net/atl1/atl1_main.c      2007-09-04 10:12:38.000000000 -0400
> +++ b/drivers/net/atl1/atl1_main.c      2007-09-04 11:23:26.000000000 -0400
> @@ -2203,22 +2203,26 @@ static int __devinit atl1_probe(struct p
>         struct net_device *netdev;
>         struct atl1_adapter *adapter;
>         static int cards_found = 0;
> -       bool pci_using_64 = true;
> +       bool pci_using_64 = false;
>         int err;
>
>         err = pci_enable_device(pdev);
>         if (err)
>                 return err;
>
> +#ifdef CONFIG_ATL1_EXPERIMENTAL
>         err = pci_set_dma_mask(pdev, DMA_64BIT_MASK);
> +       if (!err) {
> +               pci_using_64 = true;
> +               goto dma_ok;
> +       }
> +#endif /* CONFIG_ATL1_EXPERIMENTAL */

This is more like CONFIG_ATL1_PLEASE_KILL_MY_MACHINE; I really don't
see the problem with just limiting the DMA mask:
- if you don't have physical mem over the 4GB boundary limiting DMA
doesn't make any difference
- if you have more than 4GB of memory the machine won't survive long without it

Luca
