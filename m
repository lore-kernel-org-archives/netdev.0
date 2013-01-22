From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG in netxen_release_tx_buffers when TSO enabled on kernels
 >= 3.3 and <= 3.6
Date: Tue, 22 Jan 2013 11:59:42 -0800
Message-ID: <1358884782.12374.8.camel@edumazet-glaptop>
References: <1659861.dHpGAGoXHj@cpaasch-mac>
	 <1358861524.3464.3768.camel@edumazet-glaptop>
	 <1358862966.3464.3797.camel@edumazet-glaptop>
	 <1358883411.2892.11.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: christoph.paasch@uclouvain.be,
	Ian Campbell <Ian.Campbell@citrix.com>,
	Sony Chacko <sony.chacko@qlogic.com>,
	Rajesh Borundia <rajesh.borundia@qlogic.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:40965 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753643Ab3AVT7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 14:59:45 -0500
Received: by mail-pa0-f43.google.com with SMTP id fb10so4272059pad.16
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 11:59:45 -0800 (PST)
In-Reply-To: <1358883411.2892.11.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-01-22 at 19:36 +0000, Ben Hutchings wrote:

> There's another bug right here, which is that 0 is a valid DMA address
> in some systems.  The driver should be calling pci_dma_mapping_error()
> to find out whether an address is valid or not.  But it also wants to be
> able to assign an invalid address to netxen_skb_frag::dma, and
> unfortunately there is no way to do that in the current DMA API.
> 

I guess we should only test ->frag_count then, and set it to 0 in TX
completion path.
