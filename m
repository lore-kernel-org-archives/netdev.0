From: "Amit S. Kale" <amitkale@linsyssoft.com>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Thu, 7 Dec 2006 11:48:14 +0530
Message-ID: <200612071148.14996.amitkale@linsyssoft.com>
References: <200612011340.kB1DeEhR014690@dut39.unminc.com> <20061206101644.27eeaf14@freekitty> <20061206193328.GB3524@rhun.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
	Jeff Garzik <jeff@garzik.org>,
	"Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from svr68.ehostpros.com ([67.15.48.48]:44707 "EHLO
	svr68.ehostpros.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031656AbWLGGSA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Dec 2006 01:18:00 -0500
To: Muli Ben-Yehuda <muli@il.ibm.com>
In-Reply-To: <20061206193328.GB3524@rhun.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 07 December 2006 01:03, Muli Ben-Yehuda wrote:
> On Wed, Dec 06, 2006 at 10:16:44AM -0800, Stephen Hemminger wrote:
> > I think it is really only an issue for drivers that turn on HIGH_DMA
> > and have limited mask values. The majority of drivers either only
> > handle 32 bit (!HIGH_DMA) or do full 64 bit mapping. I don't know
> > the details of how we manage IOMMU, but doesn't mapping always work
> > for those drivers.
>
> It's up to an IOMMU (DMA-API) implementation to define what
> constitutes a mapping error, e.g., Calgary and GART on x86-64 will
> return bad_dma_address from the mapping functions when they run out of
> entries in the IO space, which can happen regardless of the mask.

We've seen IOMMU space running out on ia64 systems. Would this be the case 
with other 10G driver requiring IOMMU remapping? We need frequent map-unmap 
at near 10G throughput.

On the x86_64 boxes that don't feature iommu functionality (because the 
motherboard disables it or because Linux can't handle it) Linux bounce buffer 
framework automatically comes into picture. Could we have the same framework 
take over when IOMMU space is over? I don't think this is possible with 
present code, though. We probably can have fallback_dma_ops in addition to 
dma_ops.

-Amit
