From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ezchip: fix address space confusion in nps_enet.c
Date: Tue, 08 Dec 2015 22:58:41 -0500 (EST)
Message-ID: <20151208.225841.2073281401429339939.davem@davemloft.net>
References: <33732958.3idC7H2UPT@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: noamc@ezchip.com, talz@ezchip.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <33732958.3idC7H2UPT@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 08 Dec 2015 16:28:59 +0100

> The nps_enet driver happily mixes virtual, physical and __iomem
> addresses, which are all different depending on the architecture
> and configuration.  That causes a warning when building the code
> on ARM with LPAE mode enabled:
> 
> drivers/net/ethernet/ezchip/nps_enet.c: In function 'nps_enet_send_frame':
> drivers/net/ethernet/ezchip/nps_enet.c:370:13: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
> 
> but will also fail to work for other reasons.
> 
> In this patch, I'm trying to change the code to use only normal
> kernel pointers, which I assume is what the author actually meant:
> 
> * For reading or writing a 32-bit word that may be unaligned when
>   an SKB contains unaligned data, I'm using get_unaligned/put_unaligned()
>   rather than memcpy_fromio/toio.
> 
> * For converting a u8 pointer to a u32 pointer, I use a cast rather
>   than the incorrect virt_to_phys.
> 
> * For copying a couple of bytes from one place to another while respecting
>   alignment, I use memcpy instead of memcpy_toio.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
