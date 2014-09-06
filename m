From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] 3c59x: avoid panic in boomerang_start_xmit when
 finding page address:
Date: Fri, 05 Sep 2014 17:24:26 -0700 (PDT)
Message-ID: <20140905.172426.1277528296784403545.davem@davemloft.net>
References: <20140903.205839.970971614125053614.davem@davemloft.net>
	<1409825618-30785-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57903 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbaIFAY1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Sep 2014 20:24:27 -0400
In-Reply-To: <1409825618-30785-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Thu,  4 Sep 2014 06:13:38 -0400

> This bug was reported on a very old kernel (RHEL6, 2.6.32-491.el6):
 ...
> But the problem seems to still exist upstream.  It seems on 32 bit kernels
> page_address() can reutrn a NULL value in some circumstances, and the
> pci_map_single api isn't prepared to handle that (on this system it results in a
> bogus pointer deference in nommu_map_page.
> 
> The fix is pretty easy, if we convert the 3c59x driver to use the more
> convieient skb_frag_dma_map api we don't need to find the virtual address of the
> page at all, and page gets mapped to the hardware properly.  Verified to fix the
> problem as described by the reporter.
> 
> Applies to the net tree
> 
> Change Notes:
> 
> v2) Converted PCI_DMA_TODEVICE to DMA_TO_DEVICE.  Thanks Dave!
> 
> v3) Actually Run git commit after making changes to v2 :)
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>

Applied, thanks Neil.
