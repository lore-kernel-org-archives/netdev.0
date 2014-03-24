From: Bing Zhao <bzhao@marvell.com>
Subject: RE: [PATCH net-next 6/7] mwifiex: Remove casts of pointer to same
 type
Date: Mon, 24 Mar 2014 15:23:26 -0700
Message-ID: <477F20668A386D41ADCC57781B1F70430F53F34172@SC-VEXCH1.marvell.com>
References: <cover.1395692043.git.joe@perches.com>
 <6acb416fd1434c218ce14f2dd0878e561cc5ff9e.1395692043.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Joe Perches <joe@perches.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6acb416fd1434c218ce14f2dd0878e561cc5ff9e.1395692043.git.joe@perches.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Joe,

Thanks for the patch.

> Casting a pointer to a pointer of the same type is pointless,
> so remove these unnecessary casts.
> 
> Done via coccinelle script:
> 
> $ cat typecast_2.cocci
> @@
> type T;
> T *foo;
> @@
> 
> -	(T *)foo
> +	foo
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Acked-by: Bing Zhao <bzhao@marvell.com>

Thanks,
Bing

> ---
>  drivers/net/wireless/mwifiex/pcie.c | 6 +++---
>  drivers/net/wireless/mwifiex/scan.c | 2 +-
>  drivers/net/wireless/mwifiex/tdls.c | 6 +++---
>  3 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/wireless/mwifiex/pcie.c b/drivers/net/wireless/mwifiex/pcie.c
> index 9f1683b..c0c598d 100644
> --- a/drivers/net/wireless/mwifiex/pcie.c
> +++ b/drivers/net/wireless/mwifiex/pcie.c
> @@ -1009,7 +1009,7 @@ static int mwifiex_pcie_send_data_complete(struct mwifiex_adapter *adapter)
>  		card->tx_buf_list[wrdoneidx] = NULL;
> 
>  		if (reg->pfu_enabled) {
> -			desc2 = (void *)card->txbd_ring[wrdoneidx];
> +			desc2 = card->txbd_ring[wrdoneidx];
>  			memset(desc2, 0, sizeof(*desc2));
>  		} else {
>  			desc = card->txbd_ring[wrdoneidx];
> @@ -1094,7 +1094,7 @@ mwifiex_pcie_send_data(struct mwifiex_adapter *adapter, struct sk_buff *skb,
>  		card->tx_buf_list[wrindx] = skb;
> 
>  		if (reg->pfu_enabled) {
> -			desc2 = (void *)card->txbd_ring[wrindx];
> +			desc2 = card->txbd_ring[wrindx];
>  			desc2->paddr = buf_pa;
>  			desc2->len = (u16)skb->len;
>  			desc2->frag_len = (u16)skb->len;
> @@ -1254,7 +1254,7 @@ static int mwifiex_pcie_process_recv_data(struct mwifiex_adapter *adapter)
>  		card->rx_buf_list[rd_index] = skb_tmp;
> 
>  		if (reg->pfu_enabled) {
> -			desc2 = (void *)card->rxbd_ring[rd_index];
> +			desc2 = card->rxbd_ring[rd_index];
>  			desc2->paddr = buf_pa;
>  			desc2->len = skb_tmp->len;
>  			desc2->frag_len = skb_tmp->len;
> diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwifiex/scan.c
> index f139244..825aeec 100644
> --- a/drivers/net/wireless/mwifiex/scan.c
> +++ b/drivers/net/wireless/mwifiex/scan.c
> @@ -1653,7 +1653,7 @@ mwifiex_parse_single_response_buf(struct mwifiex_private *priv, u8 **bss_info,
>  	curr_bcn_bytes -= ETH_ALEN;
> 
>  	if (!ext_scan) {
> -		rssi = (s32) *(u8 *)current_ptr;
> +		rssi = (s32) *current_ptr;
>  		rssi = (-rssi) * 100;		/* Convert dBm to mBm */
>  		current_ptr += sizeof(u8);
>  		curr_bcn_bytes -= sizeof(u8);
> diff --git a/drivers/net/wireless/mwifiex/tdls.c b/drivers/net/wireless/mwifiex/tdls.c
> index 8cec6e4..97662a1 100644
> --- a/drivers/net/wireless/mwifiex/tdls.c
> +++ b/drivers/net/wireless/mwifiex/tdls.c
> @@ -730,13 +730,13 @@ void mwifiex_process_tdls_action_frame(struct mwifiex_private *priv,
> 
>  	if (len < (sizeof(struct ethhdr) + 3))
>  		return;
> -	if (*(u8 *)(buf + sizeof(struct ethhdr)) != WLAN_TDLS_SNAP_RFTYPE)
> +	if (*(buf + sizeof(struct ethhdr)) != WLAN_TDLS_SNAP_RFTYPE)
>  		return;
> -	if (*(u8 *)(buf + sizeof(struct ethhdr) + 1) != WLAN_CATEGORY_TDLS)
> +	if (*(buf + sizeof(struct ethhdr) + 1) != WLAN_CATEGORY_TDLS)
>  		return;
> 
>  	peer = buf + ETH_ALEN;
> -	action = *(u8 *)(buf + sizeof(struct ethhdr) + 2);
> +	action = *(buf + sizeof(struct ethhdr) + 2);
> 
>  	/* just handle TDLS setup request/response/confirm */
>  	if (action > WLAN_TDLS_SETUP_CONFIRM)
> --
> 1.8.1.2.459.gbcd45b4.dirty
