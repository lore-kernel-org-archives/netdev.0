From: Bert Kenward <bkenward@solarflare.com>
Subject: Re: [PATCH net-next] sfc: use ALIGN macro for aligning frame sizes
Date: Tue, 1 Dec 2015 11:58:40 +0000
Message-ID: <565D8B70.6050005@solarflare.com>
References: <1448921541-13343-1-git-send-email-jarod@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	"Shradha Shah" <sshah@solarflare.com>, <netdev@vger.kernel.org>
To: Jarod Wilson <jarod@redhat.com>, <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:9557 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756067AbbLAL6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2015 06:58:48 -0500
In-Reply-To: <1448921541-13343-1-git-send-email-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/11/15 22:12, Jarod Wilson wrote:
> Don't open-code it.
> 
> CC: Solarflare linux maintainers <linux-net-drivers@solarflare.com>
> CC: Shradha Shah <sshah@solarflare.com>
> CC: netdev@vger.kernel.org
> Signed-off-by: Jarod Wilson <jarod@redhat.com>

Acked-by: Bert Kenward <bkenward@solarflare.com>

> ---
>  drivers/net/ethernet/sfc/net_driver.h | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
> index a8ddd12..746d591 100644
> --- a/drivers/net/ethernet/sfc/net_driver.h
> +++ b/drivers/net/ethernet/sfc/net_driver.h
> @@ -1502,8 +1502,9 @@ static inline struct efx_rx_buffer *efx_rx_buffer(struct efx_rx_queue *rx_queue,
>   * same cycle, the XMAC can miss the IPG altogether.  We work around
>   * this by adding a further 16 bytes.
>   */
> +#define EFX_FRAME_PAD	16
>  #define EFX_MAX_FRAME_LEN(mtu) \
> -	((((mtu) + ETH_HLEN + VLAN_HLEN + 4/* FCS */ + 7) & ~7) + 16)
> +	(ALIGN(((mtu) + ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN + EFX_FRAME_PAD), 8))
>  
>  static inline bool efx_xmit_with_hwtstamp(struct sk_buff *skb)
>  {
> 
