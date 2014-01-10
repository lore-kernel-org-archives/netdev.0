From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bnx2x: fix DMA unmapping of TSO split BDs
Date: Fri, 10 Jan 2014 13:19:16 -0500 (EST)
Message-ID: <20140110.131916.1672816831705916656.davem@davemloft.net>
References: <1389274587-6097-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, yuvalmin@broadcom.com,
	dmitry@broadcom.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41502 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751840AbaAJSTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 13:19:21 -0500
In-Reply-To: <1389274587-6097-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Thu,  9 Jan 2014 14:36:27 +0100

> bnx2x triggers warnings with CONFIG_DMA_API_DEBUG=y:
> 
>   WARNING: CPU: 0 PID: 2253 at lib/dma-debug.c:887 check_unmap+0xf8/0x920()
>   bnx2x 0000:28:00.0: DMA-API: device driver frees DMA memory with
>   different size [device address=0x00000000da2b389e] [map size=1490 bytes]
>   [unmap size=66 bytes]
> 
> The reason is that bnx2x splits a TSO BD into two BDs (headers + data)
> using one DMA mapping for both, but it uses only the length of the first
> BD when unmapping.
> 
> This patch fixes the bug by unmapping the whole length of the two BDs.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Applied and queued up for -stable, thanks.
