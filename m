From: linas@austin.ibm.com (Linas Vepstas)
Subject: Re: [PATCH 1/2] s2io: add PCI error recovery support
Date: Mon, 21 May 2007 12:07:57 -0500
Message-ID: <20070521170757.GC5921@austin.ibm.com>
References: <20070514233730.GA4511@austin.ibm.com> <78C9135A3D2ECE4B8162EBDCE82CAD77019D47CC@nekter>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>,
	linux-pci@atrey.karlin.mff.cuni.cz, netdev@vger.kernel.org,
	James.Bottomley@SteelEye.com, linux-kernel@vger.kernel.org,
	Ramkrishna Vepa <Ramkrishna.Vepa@neterion.com>,
	Rastapur Santosh <santosh.rastapur@neterion.com>,
	Leonid Grossman <Leonid.Grossman@neterion.com>,
	Sreenivasa Honnur <Sreenivasa.Honnur@neterion.com>,
	Sriram Rapuru <Sriram.Rapuru@neterion.com>
To: Sivakumar Subramani <Sivakumar.Subramani@neterion.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:49222 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756468AbXEURIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 13:08:00 -0400
Content-Disposition: inline
In-Reply-To: <78C9135A3D2ECE4B8162EBDCE82CAD77019D47CC@nekter>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 18, 2007 at 03:06:53AM -0400, Sivakumar Subramani wrote:
> Hi,
> 
> Fix looks good. I have couple of comments,
> 
> 1) Return from s2io_updt_stats function if the PCI bus is offline
> (pci_channel_offline). 
>          if (pci_channel_offline(pdev))
>                 return;

OK, missed that one.

> 2) No Need to call netif_wake_queue() in s2io_io_resume as
> netif_device_attach() will take care of calling it.

OK.

> 3) We need to return from s2io_msix_ring_handle(),
> s2io_msix_fifo_handle(), s2io_msi_handle() if the PCI channel is
> offline. Some thing similary to the below condition that is added in the
> s2io_isr()

I was thinking that these wouldn't be needed, as MSI should stop
flowing along with everything else. However, there is a small race
window where the MSI was delivered on the PCI bus, then the error was
detected, and then the kernel delivers the MSI to device driver.
The if statements should close that gap.

I'll send an updated patch shortly.

--linas
