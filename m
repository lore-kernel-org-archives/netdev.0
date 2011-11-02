From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: Add back alignment for size for __alloc_skb
Date: Thu, 03 Nov 2011 00:31:19 +0100
Message-ID: <4EB1D2C7.2070700@gmail.com>
References: <4EB1CA4F.3090403@gmail.com> <20111102.190955.1902322759075682192.davem@davemloft.net> <4EB1CEC4.3090909@gmail.com> <20111102.191716.1682282796914825621.davem@davemloft.net> <20111102231917.GN31337@atomide.com> <4EB1D05B.6020605@gmail.com> <20111102232403.GO31337@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20111102232403.GO31337@atomide.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/11/2011 00:24, Tony Lindgren wrote:


> 
> Seems to be SLOB for omap1_defconfig.
> 
> Tony


OK this makes sense now

Your patch is absolutely needed, I completely forgot about SLOB :(

since, kmalloc(386) on SLOB gives exactly ksize=386 bytes, not nearest
power of two.

[   60.305763] malloc(size=385)->ffff880112c11e38 ksize=386 -> nsize=2
[   60.305921] malloc(size=385)->ffff88007c92ce28 ksize=386 -> nsize=2
[   60.306898] malloc(size=656)->ffff88007c44ad28 ksize=656 -> nsize=272
[   60.325385] malloc(size=656)->ffff88007c575868 ksize=656 -> nsize=272
[   60.325531] malloc(size=656)->ffff88011c777230 ksize=656 -> nsize=272
[   60.325701] malloc(size=656)->ffff880114011008 ksize=656 -> nsize=272
[   60.346716] malloc(size=385)->ffff880114142008 ksize=386 -> nsize=2
[   60.346900] malloc(size=385)->ffff88011c777690 ksize=386 -> nsize=2

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Thanks !

