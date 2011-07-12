From: Felix Fietkau <nbd-p3rKhJxN3npAfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v2 04/46] net/wireless: p54: remove useless dma_sync_single_for_device(DMA_FROM_DEVICE)
Date: Tue, 12 Jul 2011 12:50:20 +0800
Message-ID: <4E1BD28C.2070704@openwrt.org>
References: <cover.1310339688.git.mirq-linux@rere.qmqm.pl> <86c8bde08b005ca7eb4806ea77aec1f3212d63fc.1310339688.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Christian Lamparter <chunkeey-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <86c8bde08b005ca7eb4806ea77aec1f3212d63fc.1310339688.git.mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 2011-07-11 8:52 AM, Micha=C5=82 Miros=C5=82aw wrote:
> Also constify pointers used in frame parsers to verify assumptions.
>
> Signed-off-by: Micha=C5=82 Miros=C5=82aw<mirq-linux-CoA6ZxLDdyEEUmgCuDUIdw@public.gmane.org>
> ---
>   drivers/net/wireless/p54/p54pci.c |    2 --
>   drivers/net/wireless/p54/txrx.c   |   22 +++++++++++-----------
>   2 files changed, 11 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless=
/p54/p54pci.c
> index 1b75317..4491d33 100644
> --- a/drivers/net/wireless/p54/p54pci.c
> +++ b/drivers/net/wireless/p54/p54pci.c
> @@ -229,8 +229,6 @@ static void p54p_check_rx_ring(struct ieee80211_h=
w *dev, u32 *index,
>   			desc->host_addr =3D cpu_to_le32(0);
>   		} else {
>   			skb_trim(skb, 0);
> -			pci_dma_sync_single_for_device(priv->pdev, dma_addr,
> -				priv->common.rx_mtu + 32, PCI_DMA_FROMDEVICE);
>   			desc->len =3D cpu_to_le16(priv->common.rx_mtu + 32);
>   		}
>
This part does not look correct to me - same issue as your ath9k change=
,=20
which I commented on earlier. I don't think this call to=20
dma_sync_single_for_device is useless

- Felix

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
