From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net-next 2/2] net: dsa: lan9303: Learn addresses on CPU
 port when bridged
Date: Tue, 24 Oct 2017 17:18:30 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40B889C8@CHN-SV-EXMX02.mchp-main.com>
References: <20171024093515.6749-1-privat@egil-hjelmeland.no>
 <20171024093515.6749-3-privat@egil-hjelmeland.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <privat@egil-hjelmeland.no>, <andrew@lunn.ch>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171024093515.6749-3-privat@egil-hjelmeland.no>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Egil,

> +static inline int lan9303_tx_use_arl(struct dsa_port *dp, u8 *dest_addr)
> +{
> +	struct lan9303 *chip = dp->ds->priv;
> +
> +	return chip->is_bridged && !ether_addr_equal(dest_addr,
> eth_stp_addr);
> +}
> 
>  static struct sk_buff *lan9303_xmit(struct sk_buff *skb, struct net_device
> *dev)
>  {
> @@ -62,7 +80,10 @@ static struct sk_buff *lan9303_xmit(struct sk_buff *skb,
> struct net_device *dev)
> 
>  	lan9303_tag = (u16 *)(skb->data + 2 * ETH_ALEN);
>  	lan9303_tag[0] = htons(ETH_P_8021Q);
> -	lan9303_tag[1] = htons(dp->index | BIT(4));
> +	lan9303_tag[1] = lan9303_tx_use_arl(dp, skb->data) ?

How about using skb_mac_header(skb) than skb->data?

> +				LAN9303_TAG_TX_USE_ALR :
> +				dp->index |

Thanks.
Woojung
