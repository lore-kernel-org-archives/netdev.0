From: Jisheng Zhang <jszhang@marvell.com>
Subject: Re: [PATCH net-next v2 0/2] net: mvneta: improve rx performance
Date: Fri, 17 Feb 2017 18:09:33 +0800
Message-ID: <20170217180933.625dab3d@xhacker>
References: <20170217100233.2325-1-jszhang@marvell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: <thomas.petazzoni@free-electrons.com>, <davem@davemloft.net>,
 <arnd@arndb.de>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170217100233.2325-1-jszhang@marvell.com>
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

On Fri, 17 Feb 2017 18:02:31 +0800
Jisheng Zhang <jszhang@marvell.com> wrote:

> In hot code path such as mvneta_rx_hwbm() and mvneta_rx_swbm(), we may
> access fields of rx_desc. The rx_desc is allocated by
> dma_alloc_coherent, it's uncacheable if the device isn't cache
> coherent, reading from uncached memory is fairly slow.
> 
> patch1 reuses the read out status to getting status field of rx_desc
> again.
> 
> patch2 uses cacheable memory to store the rx buffer DMA address.
> 
> We get the following performance data on Marvell BG4CT Platforms
> (tested with iperf):
> 
> before the patch:
> recving 1GB in mvneta_rx_swbm() costs 149265960 ns

oops, I still didn't correct the typo here, it should be 1492659600 ns

Sorry, but I think there must be comments, I'll fix this typo in v3 when
address comments.

> 
> after the patch:
> recving 1GB in mvneta_rx_swbm() costs 1421565640 ns
> 
> We saved 4.76% time.
> 
> RFC: can we do similar modification for tx? If yes, I can prepare a v2.
> 
> 
> Basically, these two patches do what Arnd mentioned in [1].
> 
> Hi Arnd,
> 
> I added "Suggested-by you" tag, I hope you don't mind ;)
> 
> Thanks
> 
> [1] https://www.spinics.net/lists/netdev/msg405889.html
> 
> Since v1:
>   - correct the performance data typo
> 
> Jisheng Zhang (2):
>   net: mvneta: avoid getting status from rx_desc as much as possible
>   net: mvneta: Use cacheable memory to store the rx buffer DMA address
> 
>  drivers/net/ethernet/marvell/mvneta.c | 36 ++++++++++++++++++++---------------
>  1 file changed, 21 insertions(+), 15 deletions(-)
> 
