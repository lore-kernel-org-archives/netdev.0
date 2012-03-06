From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v5] lpc32xx: Added ethernet driver
Date: Tue, 06 Mar 2012 16:20:17 -0500 (EST)
Message-ID: <20120306.162017.761246743182346842.davem@davemloft.net>
References: <1331067664-9124-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, baruch@tkos.co.il, ian.campbell@citrix.com,
 arnd@arndb.de, netdev@vger.kernel.org, w.sang@pengutronix.de,
 kevin.wells@nxp.com, eilong@broadcom.com, jeffrey.t.kirsher@intel.com,
 joe@perches.com, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org
To: stigge@antcom.de
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1331067664-9124-1-git-send-email-stigge@antcom.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

From: Roland Stigge <stigge@antcom.de>
Date: Tue,  6 Mar 2012 22:01:04 +0100

> +#define RXSTATUS_STATUS_ERROR \
> +	(RXSTATUS_NODESC | RXSTATUS_OVERRUN | RXSTATUS_ALIGN | RXSTATUS_RANGE \
> +	 | RXSTATUS_LENGTH | RXSTATUS_SYMBOL | RXSTATUS_CRC)

Should be:

#define RXSTATUS_STATUS_ERROR \
	(RXSTATUS_NODESC | RXSTATUS_OVERRUN | RXSTATUS_ALIGN | RXSTATUS_RANGE | \
	 RXSTATUS_LENGTH | RXSTATUS_SYMBOL | RXSTATUS_CRC)

> +static int lpc_eth_hard_start_xmit(struct sk_buff *skb,
> +	struct net_device *ndev);

Should be:

static int lpc_eth_hard_start_xmit(struct sk_buff *skb,
				   struct net_device *ndev);

> +struct txrx_desc_t {
> +	u32 packet;
> +	u32 control;
> +};
> +struct rx_status_t {
> +	u32 statusinfo;
> +	u32 statushashcrc;
> +};

What is the endianness of these descriptors?  Based upon the answer to
that question use __be32 or __le32  instead of u32.

> +static void __lpc_eth_clock_enable(struct netdata_local *pldat,
> +	int enable)

Should be:

static void __lpc_eth_clock_enable(struct netdata_local *pldat,
				   int enable)

And you should also use "bool" for enable and pass in true/false
at the call sites.

> +	writel((LPC_MACINT_RXDONEINTEN | LPC_MACINT_TXDONEINTEN),
> +		LPC_ENET_INTENABLE(regbase));

Should be:

	writel((LPC_MACINT_RXDONEINTEN | LPC_MACINT_TXDONEINTEN),
	       LPC_ENET_INTENABLE(regbase));

> +	/* Setup base addresses in hardware to point to buffers and
> +	   descriptors */

Should be:

	/* Setup base addresses in hardware to point to buffers and
	 * descriptors.
	 */

> +	writel((ENET_TX_DESC - 1),
> +		LPC_ENET_TXDESCRIPTORNUMBER(pldat->net_base));

All of these writel() calls are improperly indented on the second and
any subsequent lines just like the one I pointed out above, fix them
all.

> +MODULE_LICENSE("GPL");
> +

Tailing empty line in this file, please remove.
