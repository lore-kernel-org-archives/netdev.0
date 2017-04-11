From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 2/2] net: ethernet: mediatek: fix inconsistency of
 port number carried in TXD
Date: Tue, 11 Apr 2017 10:35:35 -0400 (EDT)
Message-ID: <20170411.103535.2136552403177283944.davem@davemloft.net>
References: <1491894754-16384-1-git-send-email-sean.wang@mediatek.com>
        <1491894754-16384-3-git-send-email-sean.wang@mediatek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john@phrozen.org, nbd@openwrt.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mediatek@lists.infradead.org,
        keyhaede@gmail.com
To: sean.wang@mediatek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1491894754-16384-3-git-send-email-sean.wang@mediatek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: <sean.wang@mediatek.com>
Date: Tue, 11 Apr 2017 15:12:34 +0800

> @@ -410,12 +410,18 @@ struct mtk_hw_stats {
>  	struct u64_stats_sync	syncp;
>  };
>  
> -/* PDMA descriptor can point at 1-2 segments. This enum allows us to track how
> - * memory was allocated so that it can be freed properly
> - */
>  enum mtk_tx_flags {
> +	/* PDMA descriptor can point at 1-2 segments. This enum allows us to
> +	 * track how memory was allocated so that it can be freed properly.
> +	 */
>  	MTK_TX_FLAGS_SINGLE0	= 0x01,
>  	MTK_TX_FLAGS_PAGE0	= 0x02,
> +
> +	/* MTK_TX_FLAGS_FPORTx allows tracking which port the transmitted
> +	 * SKB out instead of looking up through hardware TX descriptor.
> +	 */
> +	MTK_TX_FLAGS_FPORT1	= 0x03,
> +	MTK_TX_FLAGS_FPORT0	= 0x04,
>  };

You're creating a confusing situation here and asking for bugs to be introduced
into the driver.

The existing two enumeration values are "bit masks", but these two new values
are bit numbers and must be used with BIT().

Make them consistent, and I would suggest to make all of them bit masks, thus:

	MTK_TX_FLAGS_FPORT1	= 0x04,
	MTK_TX_FLAGS_FPORT0	= 0x08,

And then remove the use of BIT() to these values.

Thanks.
