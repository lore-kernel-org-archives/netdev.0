From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] tehuti: driver for Tehuti 10GbE network adapters
Date: Tue, 18 Sep 2007 10:47:23 +0100
Message-ID: <20070918094723.GA2539@infradead.org>
References: <20070911164033.GA3754@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, davem@davemloft.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, baum@tehutinetworks.net
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:60012 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444AbXIRJrc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 05:47:32 -0400
Content-Disposition: inline
In-Reply-To: <20070911164033.GA3754@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some comment from looking at the driver in the -mm tree:

 - please kill the CPU_CHIP_SWAP macros and use the normal linux
   cpu_to_le*/le*_to_cpu and verify them using sparse.
   See Documentation/sparse.txt on how to do that
 - please include the linux header in the .c file, not the .h
 - please don't redefine the dma mask constants
 - please use the firmware loader instead of mebedding a firmware
   image
 - please don't invent your own debugging macros but use
   dev_dbg and friends
 - please kill the ENTER/RET macros
 - please kill BDX_ASSERT
 - the unregister_netdev directly followed by free_netdev in
   bdx_remove look buggy, but I'm not entirely sure how to handle
   multi-port devices properly here.
 - please declare bdx_ethtool_ops on file-scope and kill
   bdx_ethtool_ops
 - please don't put assignments into conditionals ala

	if ((err = pci_request_regions(pdev, BDX_DRV_NAME)))
		goto err_dma;

   but rather write

	err = pci_request_regions(pdev, BDX_DRV_NAME);
	if (err)
		goto err_dma;
