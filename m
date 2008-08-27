From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] ibmveth: fix bad UDP checksums
Date: Wed, 27 Aug 2008 05:37:49 -0400
Message-ID: <48B5206D.2010502@garzik.org>
References: <20080820190826.24896.41095.62294@soporte.mitelefono.ec>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Santiago Leon <santil@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:59114 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755171AbYH0Jhx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Aug 2008 05:37:53 -0400
In-Reply-To: <20080820190826.24896.41095.62294@soporte.mitelefono.ec>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Santiago Leon wrote:
> This patch fixes a ibmveth bug where bad UDP checksums are being transmitted 
> when checksum offloading is enabled.
> The hypervisor does checksum offloading only on TCP packets, so ibmveth calls 
> skb_checksum_help() for any other protocol.  The bug happens because 
> the packet is being modified after the DMA map, so we would need a memory 
> barrier before making the hypervisor call.  Reordering the code so that the 
> DMA map happens after skb_checksum_help() has the additional advantage of 
> fixing a DMA map leak if skb_checksum_help() where to fail.
> 
> Please consider applying.
> 
> Signed-off-by: Santiago Leon <santil@us.ibm.com>
> ---
> 
>  ibmveth.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)

applied


