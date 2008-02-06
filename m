From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] e1000: Fix for 32 bits platforms with 64 bits resources
Date: Wed, 06 Feb 2008 07:13:54 -0500
Message-ID: <47A9A482.1060405@garzik.org>
References: <20071116073821.548CCDDDF4@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jgarzik@pobox.com
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40334 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761745AbYBFMN5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 07:13:57 -0500
In-Reply-To: <20071116073821.548CCDDDF4@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benjamin Herrenschmidt wrote:
> The e1000 driver stores the content of the PCI resources into
> unsigned long's before ioremapping. This breaks on 32 bits
> platforms that support 64 bits MMIO resources such as ppc 44x.
> 
> This fixes it by removing those temporary variables and passing
> directly the result of pci_resource_start/len to ioremap.
> 
> The side effect is that I removed the assignments to the netdev
> fields mem_start, mem_end and base_addr, which are totally useless
> for PCI devices.
> 
> Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
> --
> 
>  drivers/net/e1000/e1000_main.c |   18 +++++-------------
>  1 file changed, 5 insertions(+), 13 deletions(-)

applied


