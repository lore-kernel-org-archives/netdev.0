From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v3] 3c59x: avoid panic in boomerang_start_xmit when
 finding page address:
Date: Sun, 7 Sep 2014 16:43:59 -0400
Message-ID: <20140907204359.GA16055@localhost.localdomain>
References: <20140903.205839.970971614125053614.davem@davemloft.net>
 <1409825618-30785-1-git-send-email-nhorman@tuxdriver.com>
 <20140905.172426.1277528296784403545.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51221 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752684AbaIGUoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 16:44:10 -0400
Content-Disposition: inline
In-Reply-To: <20140905.172426.1277528296784403545.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 05, 2014 at 05:24:26PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Thu,  4 Sep 2014 06:13:38 -0400
> 
> > This bug was reported on a very old kernel (RHEL6, 2.6.32-491.el6):
>  ...
> > But the problem seems to still exist upstream.  It seems on 32 bit kernels
> > page_address() can reutrn a NULL value in some circumstances, and the
> > pci_map_single api isn't prepared to handle that (on this system it results in a
> > bogus pointer deference in nommu_map_page.
> > 
> > The fix is pretty easy, if we convert the 3c59x driver to use the more
> > convieient skb_frag_dma_map api we don't need to find the virtual address of the
> > page at all, and page gets mapped to the hardware properly.  Verified to fix the
> > problem as described by the reporter.
> > 
> > Applies to the net tree
> > 
> > Change Notes:
> > 
> > v2) Converted PCI_DMA_TODEVICE to DMA_TO_DEVICE.  Thanks Dave!
> > 
> > v3) Actually Run git commit after making changes to v2 :)
> > 
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Applied, thanks Neil.
> 
Thanks Dave!
Neil
