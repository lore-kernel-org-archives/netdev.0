From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH] skge: use unique IRQ name
Date: Thu, 1 Oct 2009 20:02:08 +0200
Message-ID: <20091001200208.2907b8ff@leela>
References: <20090922120127.14242.71353.stgit@localhost.localdomain>
	<20090922092826.5302225c@s6510>
	<20091001122720.3822bdd3@leela>
	<20091001095032.17271dcc@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61513 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758AbZJAR5C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2009 13:57:02 -0400
In-Reply-To: <20091001095032.17271dcc@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne Thu, 1 Oct 2009 09:50:32 -0700 Stephen Hemminger napsal:
>  	err = -ENOMEM;
> -	hw = kzalloc(sizeof(*hw), GFP_KERNEL);
> +	/* space for skge@pci:0000:04:00.0 */
> +	irq_name_len = strlen(DRV_NAME) +
> strlen(dev_name(&pdev->dev)) + 6;

You replaced "dev_name(&pdev->dev)" with "pci_name(pdev)" below.
That's nice, so we should replace it here too for consistency.

> +	hw = kzalloc(sizeof(*hw) + irq_name_len, GFP_KERNEL);
>  	if (!hw) {
>  		dev_err(&pdev->dev, "cannot allocate hardware
> struct\n"); goto err_out_free_regions;
>  	}
> +	sprintf(hw->irq_name, DRV_NAME "@pci:%s", pci_name(pdev));

Michal
