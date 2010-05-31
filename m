From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: Use __this_cpu_inc() in fast path
Date: Mon, 31 May 2010 00:30:07 -0700 (PDT)
Message-ID: <20100531.003007.112615604.davem@davemloft.net>
References: <1274342843.4046.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54277
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756218Ab0EaH35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 03:29:57 -0400
In-Reply-To: <1274342843.4046.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 20 May 2010 10:07:23 +0200

> This patch saves 224 bytes of text on my machine.
> 
> __this_cpu_inc() generates a single instruction, using no scratch
> registers :
> 
>   65 ff 04 25 a8 30 01 00      incl   %gs:0x130a8
> 
> instead of :
> 
>   48 c7 c2 80 30 01 00         mov    $0x13080,%rdx
>   65 48 8b 04 25 88 ea 00 00   mov    %gs:0xea88,%rax
>   83 44 10 28 01               addl   $0x1,0x28(%rax,%rdx,1)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
