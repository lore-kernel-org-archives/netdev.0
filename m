From: Joe Perches <joe@perches.com>
Subject: Re: [net-next PATCH v3] net: ethernet driver: Fujitsu OGMA
Date: Sun, 15 Jun 2014 09:14:46 -0700
Message-ID: <1402848886.2695.8.camel@joe-AO725>
References: <20140615042109.30580.8558.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	patches@linaro.org, Francois Romieu <romieu@fr.zoreil.com>
To: Andy Green <andy.green@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0220.hostedemail.com ([216.40.44.220]:45072 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750758AbaFOQOt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Jun 2014 12:14:49 -0400
In-Reply-To: <20140615042109.30580.8558.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-06-15 at 12:21 +0800, Andy Green wrote:
> This driver adds support for "ogma", a Fujitsu Semiconductor Ltd IP Gigabit
> Ethernet + PHY IP used in a variety of their ARM-based ASICs.

trivia: (nothing to stop this, could be acted on later)

> diff --git a/drivers/net/ethernet/fujitsu/ogma/ogma.h b/drivers/net/ethernet/fujitsu/ogma/ogma.h
[]
> +struct ogma_gmac_mode {
> +	u32 half_duplex_flag:1;
> +	u32 flow_ctrl_enable_flag:1;
> +	u8 link_speed;
> +	u16 flow_start_th;
> +	u16 flow_stop_th;
> +	u16 pause_time;
> +};

These structures seem inefficiently packed.
Perhaps reordering members might make sense.

> +struct ogma_desc_ring {
> +	unsigned int id;
> +	bool running;
> +	u32 full:1;
> +	u8 len;

Maybe
	bool running;
	bool full;
	u8 len;

[]

> +int ogma_alloc_desc_ring(struct ogma_priv *priv, unsigned int id)
> +{
[]
> +	desc->ring_vaddr = dma_alloc_coherent(priv->dev, desc->len * DESC_NUM,
[]
> +	memset(desc->ring_vaddr, 0, desc->len * DESC_NUM);

There is a dma_zalloc_coherent

> +int ogma_get_rx_pkt_data(struct ogma_priv *priv,
> +			 struct ogma_rx_pkt_info *rxpi,
> +			 struct ogma_frag_info *frag, u16 *len,
> +			 struct sk_buff **skb)
> +{
[]
> +	if (alloc_rx_pkt_buf(priv, &info, &info.addr, &info.paddr, &tmp_skb)) {
> +		netif_err(priv, drv, priv->net_device,
> +			  "%s: alloc_rx_pkt_buf fail\n", __func__);

Likely none of these OOM messages are
useful/necessary.  A generic OOM message is
emitted by the kernel memory subsystem.
