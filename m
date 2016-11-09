From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bna: Add synchronization for tx ring.
Date: Wed, 09 Nov 2016 13:32:33 -0500 (EST)
Message-ID: <20161109.133233.218503199113292279.davem@davemloft.net>
References: <20161107095756.15343-1-bpoirier@suse.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rasesh.mody@cavium.com,
        sudarsana.kalluru@cavium.com, Dept-GELinuxNICDev@cavium.com
To: bpoirier@suse.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38696 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752429AbcKIScf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:32:35 -0500
In-Reply-To: <20161107095756.15343-1-bpoirier@suse.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>
Date: Mon,  7 Nov 2016 17:57:56 +0800

> We received two reports of BUG_ON in bnad_txcmpl_process() where
> hw_consumer_index appeared to be ahead of producer_index. Out of order
> write/read of these variables could explain these reports.
> 
> bnad_start_xmit(), as a producer of tx descriptors, has a few memory
> barriers sprinkled around writes to producer_index and the device's
> doorbell but they're not paired with anything in bnad_txcmpl_process(), a
> consumer.
> 
> Since we are synchronizing with a device, we must use mandatory barriers,
> not smp_*. Also, I didn't see the purpose of the last smp_mb() in
> bnad_start_xmit().
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.com>

Applied.
