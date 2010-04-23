From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] fsl_pq_mdio: Fix kernel oops during OF address
 translation
Date: Fri, 23 Apr 2010 16:20:41 -0700 (PDT)
Message-ID: <20100423.162041.158531826.davem@davemloft.net>
References: <20100423171235.GA2140@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sandeep.Kumar@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: avorontsov@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751624Ab0DWXUh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 19:20:37 -0400
In-Reply-To: <20100423171235.GA2140@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Vorontsov <avorontsov@mvista.com>
Date: Fri, 23 Apr 2010 21:12:35 +0400

> Old P1020RDB device trees were not specifing tbipa address for
> MDIO nodes, which is now causing this kernel oops:
> 
>  ...
>  eth2: TX BD ring size for Q[6]: 256
>  eth2: TX BD ring size for Q[7]: 256
>  Unable to handle kernel paging request for data at address 0x00000000
>  Faulting instruction address: 0xc0015504
>  Oops: Kernel access of bad area, sig: 11 [#1]
>  ...
>  NIP [c0015504] memcpy+0x3c/0x9c
>  LR [c000a9f8] __of_translate_address+0xfc/0x21c
>  Call Trace:
>  [df839e00] [c000a94c] __of_translate_address+0x50/0x21c (unreliable)
>  [df839e50] [c01a33e8] get_gfar_tbipa+0xb0/0xe0
>  ...
> 
> The old device trees are buggy, though having a dead ethernet is
> better than a dead kernel, so fix the issue by using of_iomap().
> 
> Also, a somewhat similar issue exist in the probe() routine, though
> there the oops is only a possibility. Nonetheless, fix it too.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@mvista.com>

Seems reasonable, applied to net-2.6 thanks!
