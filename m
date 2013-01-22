From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: BUG in netxen_release_tx_buffers when TSO enabled on kernels >= 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 17:55:04 +0100
Message-ID: <2183571.Vc2rij2V9M@cpaasch-mac>
References: <1659861.dHpGAGoXHj@cpaasch-mac> <3172160.NCYvLW6RVJ@cpaasch-mac> <1358872385.3464.3940.camel@edumazet-glaptop>
Reply-To: christoph.paasch@uclouvain.be
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:37097 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885Ab3AVQzI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 11:55:08 -0500
Received: by mail-wi0-f181.google.com with SMTP id hq4so6107113wib.14
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 08:55:07 -0800 (PST)
In-Reply-To: <1358872385.3464.3940.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 January 2013 08:33:05 Eric Dumazet wrote:
> [PATCH] netxen: fix off by one bug in netxen_release_tx_buffer()
> 
> Christoph Paasch found netxen could trigger a BUG in its dismantle
> phase, in netxen_release_tx_buffer(), using full size TSO packets.
> 
> cmd_buf->frag_count includes the skb->data part, so the loop must
> start at index 1 instead of 0, or else we can make an out
> of bound access to cmd_buff->frag_array[MAX_SKB_FRAGS + 2]
> 
> Christoph provided the fixes in netxen_map_tx_skb() function.
> In case of a dma mapping error, its better to clear the dma fields
> so that we don't try to unmap them again in netxen_release_tx_buffer()
> 
> Reported-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> Cc: Sony Chacko <sony.chacko@qlogic.com>
> Cc: Rajesh Borundia <rajesh.borundia@qlogic.com>
> ---
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c |    2 +-
>  drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c |    2 ++
>  2 files changed, 3 insertions(+), 1 deletion(-)

Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>


-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
UCLouvain
--
