From: "Alexander Indenbaum" <baum@tehutinetworks.net>
Subject: RE: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Wed, 19 Sep 2007 12:44:33 +0200
Message-ID: <20070919104438.B1FF775CAD@mail.tehutinetworks.co.il>
References: <20070918094723.GA2539@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: <jeff@garzik.org>, <davem@davemloft.org>,
	<akpm@linux-foundation.org>, <netdev@vger.kernel.org>,
	"'Nadav Shemer'" <nadav@tehutinetworks.net>,
	"'Andy Gospodarek'" <andy@greyhouse.net>
To: "'Christoph Hellwig'" <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bzq-219-225-50.pop.bezeqint.net ([62.219.225.50]:34003 "EHLO
	mail.tehutinetworks.co.il" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751171AbXISKov (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 06:44:51 -0400
In-Reply-To: <20070918094723.GA2539@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christoph,

Thank you for reviewing the driver and giving us this feedback. Our goal is
the driver which is in full accordance with all Linux kernel style
guidelines. Please note the fist Tehuti driver submission to netdev was by
Andy on Mars 15 and since the driver has been heavily re-factored based on
Jeff's suggestions. I agree with most of your style remarks and we'll
release the patch soon.

Meanwhile let me ask clarification about two of your remarks bellow that I'm
not sure I fully understand.

> -----Original Message-----
> From: Christoph Hellwig [mailto:hch@infradead.org]
> Sent: Tuesday, September 18, 2007 11:47 AM
> To: Andy Gospodarek
> Cc: jeff@garzik.org; davem@davemloft.org; akpm@linux-foundation.org;
> netdev@vger.kernel.org; baum@tehutinetworks.net
> Subject: Re: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
> 
> 
> Some comment from looking at the driver in the -mm tree:
> 
>  - please kill the CPU_CHIP_SWAP macros and use the normal linux
>    cpu_to_le*/le*_to_cpu and verify them using sparse.
>    See Documentation/sparse.txt on how to do that
>  - please include the linux header in the .c file, not the .h
>  - please don't redefine the dma mask constants
>  - please use the firmware loader instead of mebedding a firmware
>    image

Could you give us some pointers to docs and examples of "firmware loader"?
I'm not sure I'm familiar with such mechanism in Linux kernel.

>  - please don't invent your own debugging macros but use
>    dev_dbg and friends
>  - please kill the ENTER/RET macros
>  - please kill BDX_ASSERT
>  - the unregister_netdev directly followed by free_netdev in
>    bdx_remove look buggy, but I'm not entirely sure how to handle
>    multi-port devices properly here.

Putting dual-port issue aside, could you elaborate what is the problem in
your opinion in bdx_remove() implementation? What is wrong with calling
free_netdev() right after unregister_netdev()? Could you provide pointers
for docs and examples to correct PCI network device remove interface
implementation? 

>  - please declare bdx_ethtool_ops on file-scope and kill
>    bdx_ethtool_ops
>  - please don't put assignments into conditionals ala
> 
> 	if ((err = pci_request_regions(pdev, BDX_DRV_NAME)))
> 		goto err_dma;
> 
>    but rather write
> 
> 	err = pci_request_regions(pdev, BDX_DRV_NAME);
> 	if (err)
> 		goto err_dma;

Thank you again for your help,
Alexander Indenbaum


