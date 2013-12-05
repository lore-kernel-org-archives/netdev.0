From: "Maciej W. Rozycki" <macro@linux-mips.org>
Subject: Re: [PATCH 2/2] net/fddi: Replace local marco with PCI standard
 macro
Date: Thu, 5 Dec 2013 22:06:59 +0000 (GMT)
Message-ID: <alpine.LFD.2.10.1312052154190.1599@eddie.linux-mips.org>
References: <1386243482-32856-1-git-send-email-wangyijing@huawei.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Hanjun Guo <guohanjun@huawei.com>
To: Yijing Wang <wangyijing@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386243482-32856-1-git-send-email-wangyijing@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 5 Dec 2013, Yijing Wang wrote:

> Replace local marco DFX_BUS_PCI with PCI standard marco
> dev_is_pci().

 Typos above: marco -> macro

> Signed-off-by: Yijing Wang <wangyijing@huawei.com>
> ---
>  drivers/net/fddi/defxx.c |   20 +++++++-------------
>  1 files changed, 7 insertions(+), 13 deletions(-)
> 
> diff --git a/drivers/net/fddi/defxx.c b/drivers/net/fddi/defxx.c
> index 0b40e1c..0344f71 100644
> --- a/drivers/net/fddi/defxx.c
> +++ b/drivers/net/fddi/defxx.c
> @@ -241,12 +241,6 @@ static char version[] =
>   */
>  #define NEW_SKB_SIZE (PI_RCV_DATA_K_SIZE_MAX+128)
>  
> -#ifdef CONFIG_PCI
> -#define DFX_BUS_PCI(dev) (dev->bus == &pci_bus_type)
> -#else
> -#define DFX_BUS_PCI(dev) 0
> -#endif
> -
>  #ifdef CONFIG_EISA
>  #define DFX_BUS_EISA(dev) (dev->bus == &eisa_bus_type)
>  #else
> @@ -436,7 +430,7 @@ static void dfx_port_read_long(DFX_board_t *bp, int offset, u32 *data)
>  static void dfx_get_bars(struct device *bdev,
>  			 resource_size_t *bar_start, resource_size_t *bar_len)
>  {
> -	int dfx_bus_pci = DFX_BUS_PCI(bdev);
> +	int dfx_bus_pci = dev_is_pci(bdev);
>  	int dfx_bus_eisa = DFX_BUS_EISA(bdev);
>  	int dfx_bus_tc = DFX_BUS_TC(bdev);
>  	int dfx_use_mmio = DFX_MMIO || dfx_bus_tc;

Acked-by: Maciej W. Rozycki <macro@linux-mips.org>

  Maciej
