From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: BUG in netxen_release_tx_buffers when TSO enabled on kernels >= 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 16:03:59 +0100
Message-ID: <2166577.r0iRQtU7qE@cpaasch-mac>
References: <1659861.dHpGAGoXHj@cpaasch-mac> <1358861524.3464.3768.camel@edumazet-glaptop> <1358862966.3464.3797.camel@edumazet-glaptop>
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
Received: from mail-wi0-f174.google.com ([209.85.212.174]:48585 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753186Ab3AVPEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 10:04:04 -0500
Received: by mail-wi0-f174.google.com with SMTP id hq4so8216211wib.13
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 07:04:02 -0800 (PST)
In-Reply-To: <1358862966.3464.3797.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 January 2013 05:56:06 Eric Dumazet wrote:
> I guess netxen driver has a bug.
> 
> Please try the following patch :
> 
> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c index
> bc165f4..695667d 100644
> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_init.c
> @@ -144,7 +144,7 @@ void netxen_release_tx_buffers(struct netxen_adapter
> *adapter) buffrag->length, PCI_DMA_TODEVICE); buffrag->dma = 0ULL;
>                 }
> -               for (j = 0; j < cmd_buf->frag_count; j++) {
> +               for (j = 1; j < cmd_buf->frag_count; j++) {
>                         buffrag++;
>                         if (buffrag->dma) {
>                                 pci_unmap_page(adapter->pdev, buffrag->dma,

Perfect, I tested it, and this fixes the bug.

I should have found it on my own, I have been starring for too long at this 
function... :)

Feel free to add
Tested-by: Christoph Paasch <christoph.paasch@uclouvain.be>


Thanks, Eric!


Christoph


-- 
IP Networking Lab --- http://inl.info.ucl.ac.be
MultiPath TCP in the Linux Kernel --- http://mptcp.info.ucl.ac.be
UCLouvain
--
