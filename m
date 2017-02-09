From: Christoph Hellwig <hch@lst.de>
Subject: interrupt handling in the new aquantia ethernet driver
Date: Thu, 9 Feb 2017 15:01:57 +0100
Message-ID: <20170209140157.GA13338@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:52558 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752260AbdBIOIo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 09:08:44 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

commit a4d36e20 ("net: ethernet: aquantia: PCI operations") adds some
realy odd interrupt related code, including a call to the long
gone pci_enable_msix() function.  I first wondered how this compiles.
but the code happens to be under

#if AQ_CFG_FORCE_LEGACY_INT

where AQ_CFG_FORCE_LEGACY_INT is defined to 0U, so it isn't compiled in,
although probably not intentionally.  

It would be good to a) kill that ifdef and b) either remove the MSI-X
code entirely or switch it to the proper pci_alloc_irq_vectors API.
