From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: Add MOXA ART SoCs ethernet driver
Date: Wed, 31 Jul 2013 17:04:46 -0700 (PDT)
Message-ID: <20130731.170446.1534643901297918794.davem@davemloft.net>
References: <1374842890-20735-1-git-send-email-jonas.jensen@gmail.com>
	<1375280401-5564-1-git-send-email-jonas.jensen@gmail.com>
	<1375296998.5729.8.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jonas.jensen@gmail.com, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	arm@kernel.org, florian@openwrt.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1375296998.5729.8.camel@joe-AO722>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Wed, 31 Jul 2013 11:56:38 -0700

>> +		if (ui & (RX_ERR | CRC_ERR | FTL | RUNT | RX_ODD_NB)) {
>> +			netdev_err(ndev, "packet error\n");
> 
> This is generally a bad idea as it can flood
> the log.  It's probably better to remove it.
> If you really want logging, then at least use
> net_ratelimit().  Generally, the stats are
> enough.
 ...
>> +			priv->stats.rx_dropped++;
>> +			priv->stats.rx_errors++;
> []
>> +static int moxart_mac_start_xmit(struct sk_buff *skb, struct net_device *ndev)
> []
>> +	if (txdesc->txdes0.ubit.tx_dma_own) {
>> +		netdev_err(ndev, "no TX space for packet\n");
>> +		priv->stats.tx_dropped++;
> 
> here too.

Agreed, these should not be logged, the statistics are sufficient.
