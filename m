From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: ec_bhf: remove excessive debug messages
Date: Thu, 21 Aug 2014 16:39:18 -0700 (PDT)
Message-ID: <20140821.163918.1714927909558457176.davem@davemloft.net>
References: <20140815154941.GA16632@newterm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: reksio@newterm.pl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140815154941.GA16632@newterm.pl>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dariusz Marcinkiewicz <reksio@newterm.pl>
Date: Fri, 15 Aug 2014 17:49:41 +0200

> This cuts down on the number of debug information spit out by
> the driver. Some of the potentially useful debug info gets exposed
> by debugfs.
> 
> Signed-off-by: Dariusz Marcinkiewicz <reksio@newterm.pl>

I think you should just flat out remove a lot of this stuff:

> +static struct debugfs_reg32 ec_bhf_debugfs_mii_regs[] = {
> +	{
> +		.name = "link-status",
> +		.offset = MII_LINK_STATUS
> +	}
> +};

This is completely unnecessary, if you want to export MII register
values to the user, we have a mechanism for that, via the SIOCGMII*
ioctls.

> +static struct debugfs_reg32 ec_bhf_debugfs_fifo_regs[] = {
> +	{
> +		.name = "fifo-tx",
> +		.offset = FIFO_TX_REG
> +	},
> +	{
> +		.name = "fifo-rx",
> +		.offset = FIFO_RX_REG
> +	}
> +};

You can export chip register values via the ethtool register dump API.
Simply implement ethtool_ops->get_regs_len and ethtool_ops->get_regs
and off you go.
