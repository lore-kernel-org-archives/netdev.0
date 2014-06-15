From: Nick Krause <xerofoify@gmail.com>
Subject: Re: [PATCH] Missing return check against Null for return value of netdev_alloc_dev_skb()
Date: Sun, 15 Jun 2014 00:39:21 -0400
Message-ID: <CAPDOMVhAZvh5SDB0E4BRhEnuJm0OksdAjHWxCKphagZuohqbqw@mail.gmail.com>
References: <1402805139-6363-1-git-send-email-xerofoify@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: andriy.shevchenko@linux.intel.com, dvhart@linux.intel.com,
	jeffrey.t.kirsher@intel.com, ast@plumgrid.com, dborkman@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	bwh@kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402805139-6363-1-git-send-email-xerofoify@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am resending this patch as the email for Ben is wrong in the
maintainer script due to getting automated message from solarflare.
Signed-off-by: Nick <xerofoify@gmail.com>
---
 drivers/net/ethernet/oki-semi/
pch_gbe/pch_gbe_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 73e6683..704cf63 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -1515,6 +1515,8 @@ static void pch_gbe_alloc_tx_buffers(struct
pch_gbe_adapter *adapter,
        for (i = 0; i < tx_ring->count; i++) {
                buffer_info = &tx_ring->buffer_info[i];
                skb = netdev_alloc_skb(adapter->netdev, bufsz);
+               if (!skb)
+                       return NULL;
                skb_reserve(skb, PCH_GBE_DMA_ALIGN);
                buffer_info->skb = skb;
                tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
Thanks Nick

On Sun, Jun 15, 2014 at 12:05 AM, Nick <xerofoify@gmail.com> wrote:
> Signed-off-by: Nick <xerofoify@gmail.com>
> ---
>  drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c | 2 ++
>  1 file changed, 2 insertions(+)
>
> diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> index 73e6683..704cf63 100644
> --- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> +++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
> @@ -1515,6 +1515,8 @@ static void pch_gbe_alloc_tx_buffers(struct pch_gbe_adapter *adapter,
>         for (i = 0; i < tx_ring->count; i++) {
>                 buffer_info = &tx_ring->buffer_info[i];
>                 skb = netdev_alloc_skb(adapter->netdev, bufsz);
> +               if (!skb)
> +                       return NULL;
>                 skb_reserve(skb, PCH_GBE_DMA_ALIGN);
>                 buffer_info->skb = skb;
>                 tx_desc = PCH_GBE_TX_DESC(*tx_ring, i);
> --
> 1.9.1
>
