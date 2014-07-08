From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] declance: Fix 64-bit compilation warnings
Date: Tue, 08 Jul 2014 14:05:02 -0700 (PDT)
Message-ID: <20140708.140502.2094195777978560656.davem@davemloft.net>
References: <alpine.LFD.2.11.1407030552290.15455@eddie.linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, joe@perches.com
To: macro@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54217 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137AbaGHVFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 17:05:06 -0400
In-Reply-To: <alpine.LFD.2.11.1407030552290.15455@eddie.linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Maciej W. Rozycki" <macro@linux-mips.org>
Date: Thu, 3 Jul 2014 05:56:51 +0100 (BST)

> This fixes compiler warnings:
> 
> drivers/net/ethernet/amd/declance.c: In function 'lance_init_ring':
> drivers/net/ethernet/amd/declance.c:478: warning: format '%8.8x' expects type 'unsigned int', but argument 3 has type 'long unsigned int'
> drivers/net/ethernet/amd/declance.c:487: warning: format '%8.8x' expects type 'unsigned int', but argument 3 has type 'long unsigned int'
> drivers/net/ethernet/amd/declance.c:503: warning: cast from pointer to integer of different size
> drivers/net/ethernet/amd/declance.c:520: warning: cast from pointer to integer of different size
> 
> in 64-bit compilation.  Where the value printed is an offset (whose range 
> will always fit) the cast uses a 32-bit type, otherwise, where it is a 
> host memory address, the pointer is output directly with %p.  Also the 
> remaining `0x' prefix is dropped for consistency across these messages.
> 
> Tested with both 32-bit and 64-bit compilation, as well as at the run time 
> (with the debug messages affected enabled).
> 
> Signed-off-by: Maciej W. Rozycki <macro@linux-mips.org>
> ---
>  Update from v2 switches to using the %p format specifier where
> appropriate and drops the `0x' prefix for consistency across these debug
> messages.  Please apply.

Applied to net-next, thank you.
