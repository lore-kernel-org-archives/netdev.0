From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] e1000: Fix for 32 bits platforms with 64 bits resources
Date: Fri, 23 Nov 2007 21:52:03 -0500
Message-ID: <474791D3.1090607@pobox.com>
References: <20071116073821.548CCDDDF4@ozlabs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: auke-jan.h.kok@intel.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:40542 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753659AbXKXCwI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 21:52:08 -0500
In-Reply-To: <20071116073821.548CCDDDF4@ozlabs.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

Looks good to me.  auke?


