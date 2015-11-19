From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v7] net: ethernet: add driver for Aurora VLSI NB8800
 Ethernet controller
Date: Wed, 18 Nov 2015 23:01:01 -0500 (EST)
Message-ID: <20151118.230101.2199889775612098415.davem@davemloft.net>
References: <1447867764-23075-1-git-send-email-mans@mansr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: mans@mansr.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447867764-23075-1-git-send-email-mans@mansr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mans Rullgard <mans@mansr.com>
Date: Wed, 18 Nov 2015 17:29:24 +0000

> +static int nb8800_poll(struct napi_struct *napi, int budget)
> +{
> +	struct net_device *dev = napi->dev;
> +	struct nb8800_priv *priv = netdev_priv(dev);
> +	struct nb8800_rx_desc *rxd;
> +	int work = 0;
> +	int last = priv->rx_eoc;
> +	int next;
 ...
> +		next = (last + 1) % RX_DESC_COUNT;

You should look at what the assembler looks like for these modulo
operations.

They will be much simpler (ie. one instruction) if you use unsigned
variables to hold the queue indices.

Please fix this in the entire driver.
