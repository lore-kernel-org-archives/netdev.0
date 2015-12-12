From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netcp: try to reduce type confusion in descriptors
Date: Fri, 11 Dec 2015 19:34:56 -0500 (EST)
Message-ID: <20151211.193456.188476874988011975.davem@davemloft.net>
References: <1578620.t1ANcREMZ8@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: w-kwok2@ti.com, netdev@vger.kernel.org, m-karicheri2@ti.com,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org
To: arnd@arndb.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1578620.t1ANcREMZ8@wuerfel>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Tue, 08 Dec 2015 16:32:27 +0100

> The netcp driver produces tons of warnings when CONFIG_LPAE is enabled
> on ARM:
> 
> drivers/net/ethernet/ti/netcp_core.c: In function 'netcp_tx_map_skb':
> drivers/net/ethernet/ti/netcp_core.c:1084:13: warning: passing argument 1 of 'set_words' from incompatible pointer type [-Wincompatible-pointer-types]
> 
> This is the result of trying to pass a pointer to a dma_addr_t to
> a function that expects a u32 pointer to copy that into a DMA descriptor.
> 
> Looking at that code in more detail to fix the warnings, I see multiple
> related problems:
> 
> * The conversion functions are not endian-safe, as the DMA descriptors
>   are almost certainly fixed-endian, but the CPU is not.
> 
> * On 64-bit machines, passing a pointer through a u32 variable is a
>   bug, accessing an indirect pointer as a u32 pointer even more so.
> 
> * The handling of epib and psdata mixes native-endian and device-endian
>   data.
> 
> In this patch, I try to sort out the types for most accesses here,
> adding le32_to_cpu/cpu_to_le32 where appropriate, and passing pointers
> through two 32-bit words in the descriptor padding, to make it plausible
> that the driver does the right thing if compiled for big-endian or
> 64-bit systems.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied to net-next.
