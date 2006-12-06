From: Muli Ben-Yehuda <muli@il.ibm.com>
Subject: Re: network devices don't handle pci_dma_mapping_error()'s
Date: Wed, 6 Dec 2006 21:33:28 +0200
Message-ID: <20061206193328.GB3524@rhun.ibm.com>
References: <200612011340.kB1DeEhR014690@dut39.unminc.com> <45711007.5030704@garzik.org> <20061204103949.3d05b1ff@freekitty> <20061205070045.GE3619@rhun.ibm.com> <20061206101644.27eeaf14@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jeff@garzik.org>,
	"Amit S. Kale" <amitkale@netxen.com>, netdev@vger.kernel.org,
	brazilnut@us.ibm.com, netxenproj@linsyssoft.com, rob@netxen.com,
	romieu@fr.zoreil.com, sanjeev@netxen.com, wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.de.ibm.com ([195.212.29.154]:7659 "EHLO
	mtagate5.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S937462AbWLFTdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 14:33:32 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate5.de.ibm.com (8.13.8/8.13.8) with ESMTP id kB6JXVrq066044
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 19:33:31 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id kB6JXVbd3129434
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 20:33:31 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id kB6JXUAU013876
	for <netdev@vger.kernel.org>; Wed, 6 Dec 2006 20:33:31 +0100
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061206101644.27eeaf14@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 06, 2006 at 10:16:44AM -0800, Stephen Hemminger wrote:

> I think it is really only an issue for drivers that turn on HIGH_DMA
> and have limited mask values. The majority of drivers either only
> handle 32 bit (!HIGH_DMA) or do full 64 bit mapping. I don't know
> the details of how we manage IOMMU, but doesn't mapping always work
> for those drivers.

It's up to an IOMMU (DMA-API) implementation to define what
constitutes a mapping error, e.g., Calgary and GART on x86-64 will
return bad_dma_address from the mapping functions when they run out of
entries in the IO space, which can happen regardless of the mask.

Cheers,
Muli
