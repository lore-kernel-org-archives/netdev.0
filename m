From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v6] sfc: PIO:Restrict to 64bit arch and use 64-bit
 writes.
Date: Wed, 11 Jun 2014 15:36:53 -0700 (PDT)
Message-ID: <20140611.153653.1894044183638797631.davem@davemloft.net>
References: <53985A94.3080303@solarflare.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: sshah@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47675 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbaFKWgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jun 2014 18:36:54 -0400
In-Reply-To: <53985A94.3080303@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shradha Shah <sshah@solarflare.com>
Date: Wed, 11 Jun 2014 14:33:08 +0100

> From: Jon Cooper <jcooper@solarflare.com>
> 
> Fixes:ee45fd92c739
> ("sfc: Use TX PIO for sufficiently small packets")
> 
> The linux net driver uses memcpy_toio() in order to copy into
> the PIO buffers.
> Even on a 64bit machine this causes 32bit accesses to a write-
> combined memory region.
> There are hardware limitations that mean that only 64bit
> naturally aligned accesses are safe in all cases.
> Due to being write-combined memory region two 32bit accesses
> may be coalesced to form a 64bit non 64bit aligned access.
> Solution was to open-code the memory copy routines using pointers
> and to only enable PIO for x86_64 machines.
> 
> Not tested on platforms other than x86_64 because this patch
> disables the PIO feature on other platforms.
> Compile-tested on x86 to ensure that works.
> 
> The WARN_ON_ONCE() code in the previous version of this patch
> has been moved into the internal sfc debug driver as the
> assertion was unnecessary in the upstream kernel code.
> 
> This bug fix applies to v3.13 and v3.14 stable branches.
> 
> Signed-off-by: Shradha Shah <sshah@solarflare.com>

Applied and queued up for -stable, thanks.
