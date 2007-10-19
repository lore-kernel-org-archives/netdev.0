From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [POWERPC] ucc_geth: Eliminate compile warnings
Date: Thu, 18 Oct 2007 17:30:32 -0700 (PDT)
Message-ID: <20071018.173032.48505868.davem@davemloft.net>
References: <1192745713-20829-1-git-send-email-Emilian.Medve@Freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, leoli@freescale.com, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Emilian.Medve@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58894
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756492AbXJSAaT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2007 20:30:19 -0400
In-Reply-To: <1192745713-20829-1-git-send-email-Emilian.Medve@Freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Emil Medve <Emilian.Medve@freescale.com>
Date: Thu, 18 Oct 2007 17:15:13 -0500

> drivers/net/ucc_geth.c: In function 'ucc_geth_startup':
> drivers/net/ucc_geth.c:2614: warning: assignment makes integer from pointer without a cast
> drivers/net/ucc_geth.c:2651: warning: assignment makes integer from pointer without a cast
> 
> Signed-off-by: Emil Medve <Emilian.Medve@Freescale.com>

It only kills the warning on 32-bit systems, the cast is wrong
either way.

>  			ugeth->tx_bd_ring_offset[j] =
> -				kmalloc((u32) (length + align), GFP_KERNEL);
> +				(u32)kmalloc(length + align, GFP_KERNEL);
>  
>  			if (ugeth->tx_bd_ring_offset[j] != 0)
>  				ugeth->p_tx_bd_ring[j] =

Pointers can be up to "unsigned long" in size, therefore that
is the minimal amount of storage you need to store them into
if they are needed in integer form for some reason.

Any cast from pointer to integer like this is a huge red flag.
