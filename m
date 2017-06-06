From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: stmmac: fix completely hung TX when using TSO
Date: Tue, 06 Jun 2017 16:25:02 -0400 (EDT)
Message-ID: <20170606.162502.2115422689850070963.davem@davemloft.net>
References: <20170606072501.16560-1-niklas.cassel@axis.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, alexandre.torgue@st.com, niklass@axis.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: niklas.cassel@axis.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39052 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751456AbdFFUZJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 16:25:09 -0400
In-Reply-To: <20170606072501.16560-1-niklas.cassel@axis.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Niklas Cassel <niklas.cassel@axis.com>
Date: Tue, 6 Jun 2017 09:25:00 +0200

> stmmac_tso_allocator can fail to set the Last Descriptor bit
> on a descriptor that actually was the last descriptor.
> 
> This happens when the buffer of the last descriptor ends
> up having a size of exactly TSO_MAX_BUFF_SIZE.
> 
> When the IP eventually reaches the next last descriptor,
> which actually has the bit set, the DMA will hang.
> 
> When the DMA hangs, we get a tx timeout, however,
> since stmmac does not do a complete reset of the IP
> in stmmac_tx_timeout, we end up in a state with
> completely hung TX.
> 
> Signed-off-by: Niklas Cassel <niklas.cassel@axis.com>

Applied and queued up for -stable, thank you.
