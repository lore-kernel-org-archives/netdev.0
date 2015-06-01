From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: Alloc 4k fragment for each rx ring buffer
 element
Date: Mon, 01 Jun 2015 15:57:01 -0700 (PDT)
Message-ID: <20150601.155701.499463944154053931.davem@davemloft.net>
References: <87wq02t6ce.fsf_-_@dhcp-9-18-235-171.br.ibm.com>
	<55658781.8060104@redhat.com>
	<87vbfeoteo.fsf_-_@sycorax.br.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mschmidt@redhat.com, Yuval.Mintz@qlogic.com, LinoSanfilippo@gmx.de,
	Ariel.Elior@qlogic.com, netdev@vger.kernel.org,
	cascardo@cascardo.eti.br, brking@linux.vnet.ibm.com
To: krisman@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53223 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753911AbbFAW5E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 18:57:04 -0400
In-Reply-To: <87vbfeoteo.fsf_-_@sycorax.br.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
Date: Wed, 27 May 2015 13:51:43 -0300

> Subject: [PATCH] bnx2x: Alloc 4k fragment for each rx ring buffer element
> 
> The driver allocates one page for each buffer on the rx ring, which is
> too much on architectures like ppc64 and can cause unexpected allocation
> failures when the system is under stress.  Now, we keep a memory pool
> per queue, and if the architecture's PAGE_SIZE is greater than 4k, we
> fragment pages and assign each 4k segment to a ring element, which
> reduces the overall memory consumption on such architectures.  This
> helps avoiding errors like the example below:
> 
> [bnx2x_alloc_rx_sge:435(eth1)]Can't alloc sge
> [c00000037ffeb900] [d000000075eddeb4] .bnx2x_alloc_rx_sge+0x44/0x200 [bnx2x]
> [c00000037ffeb9b0] [d000000075ee0b34] .bnx2x_fill_frag_skb+0x1ac/0x460 [bnx2x]
> [c00000037ffebac0] [d000000075ee11f0] .bnx2x_tpa_stop+0x160/0x2e8 [bnx2x]
> [c00000037ffebb90] [d000000075ee1560] .bnx2x_rx_int+0x1e8/0xc30 [bnx2x]
> [c00000037ffebcd0] [d000000075ee2084] .bnx2x_poll+0xdc/0x3d8 [bnx2x] (unreliable)
> 
> Signed-off-by: Gabriel Krisman Bertazi <krisman@linux.vnet.ibm.com>
> Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
> Reviewed-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

I think I've waited long enough on this, applied to net-next, thanks.
