From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/3] bnx2x: enlarge minimal alignemnt of data
 offset
Date: Thu, 26 Jun 2014 11:47:49 -0700
Message-ID: <1403808469.28643.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1403782266-25362-1-git-send-email-Yuval.Mintz@qlogic.com>
	 <1403782266-25362-3-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Ariel.Elior@qlogic.com, Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:43859 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750844AbaFZSry (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Jun 2014 14:47:54 -0400
Received: by mail-wi0-f177.google.com with SMTP id r20so1608822wiv.10
        for <netdev@vger.kernel.org>; Thu, 26 Jun 2014 11:47:52 -0700 (PDT)
In-Reply-To: <1403782266-25362-3-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-26 at 14:31 +0300, Yuval Mintz wrote:
> From: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
> 
> This improves the performance of driver on machine with L1_CACHE_SHIFT of at
> most 32 bytes [HW was planned for 64-byte aligned fastpath data].
> 

>  
> -	/* Max supported alignment is 256 (8 shift) */
> -#define BNX2X_RX_ALIGN_SHIFT		min(8, L1_CACHE_SHIFT)
> +	/* Max supported alignment is 256 (8 shift)
> +	 * minimal alignment shift 6 is optimal for 57xxx HW performance
> +	 */
> +#define BNX2X_RX_ALIGN_SHIFT		max(6, min(8, L1_CACHE_SHIFT))
>  
>  	/* FW uses 2 Cache lines Alignment for start packet and size
>  	 *

I would personally use clamp(L1_CACHE_SHIFT, 6, 8)

But thats probably a matter of taste...
