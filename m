From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: avoid atomic allocations during initialization
Date: Fri, 06 Sep 2013 14:27:35 -0400 (EDT)
Message-ID: <20130906.142735.458916282873797040.davem@davemloft.net>
References: <1378411989-19775-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ariele@broadcom.com, eilong@broadcom.com
To: mschmidt@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:32858 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab3IFS1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Sep 2013 14:27:38 -0400
In-Reply-To: <1378411989-19775-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michal Schmidt <mschmidt@redhat.com>
Date: Thu,  5 Sep 2013 22:13:09 +0200

> During initialization bnx2x allocates significant amounts of memory
> (for rx data, rx SGEs, TPA pool) using atomic allocations.
> 
> I received a report where bnx2x failed to allocate SGEs and it had
> to fall back to TPA-less operation.
> 
> Let's use GFP_KERNEL allocations during initialization, which runs
> in process context. Add gfp_t parameters to functions that are used
> both in initialization and in the receive path.
> 
> Use an unlikely branch in bnx2x_frag_alloc() to avoid atomic allocation
> by netdev_alloc_frag(). The branch is taken several thousands of times
> during initialization, but then never more. Note that fp->rx_frag_size
> is never greater than PAGE_SIZE, so __get_free_page() can be used here.
> 
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

This change looks good to me, if some Broadcom folks could take a look
and ACK/NACK that would be great.

Thanks.
