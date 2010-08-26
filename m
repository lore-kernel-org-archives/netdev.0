From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 08:41:29 -0700
Message-ID: <20100826084129.71b9af87@nehalam>
References: <4C763A67.5040107@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>,
	ML netdev <netdev@vger.kernel.org>,
	Greg Rose <gregory.v.rose@intel.com>,
	Maxime Bizon <mbizon@freebox.fr>,
	Kristoffer Glembo <kristoffer@gaisler.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	John Linn <john.linn@xilinx.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	MeeGo <meego-dev@meego.com>, "Wang, Qi" <qi.wang@intel.com>,
	"Wang, Yong Y" <yong.y.wang@intel.com>,
	Andrew <andrew.chih.howe.khor@intel.com>,
	Intel OTC <joel.clark@intel.com>,
	"Foster, Margie" <margie.foster@intel.com>,
	Toshiharu Okada <okada533@dsn.okisemi.com>,
	Tomoya Morinaga <morinaga526@dsn.okisemi.com>,
	Takahiro Shimizu <shimizu394@dsn.okisemi.com>
To: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37633 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753879Ab0HZPlb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Aug 2010 11:41:31 -0400
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Aug 2010 18:56:55 +0900
Masayuki Ohtake <masa-korg@dsn.okisemi.com> wrote:

> +
> +/**
> + * pch_gbe_set_settings - Set device-specific settings
> + * @netdev: Network interface device structure
> + * @ecmd:   Ethtool command
> + * Returns
> + *	0:			Successful.
> + *	Negative value:		Failed.
> + */
> +static int pch_gbe_set_settings(struct net_device *netdev,
> +				 struct ethtool_cmd *ecmd)
> +{
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +	struct pch_gbe_hw *hw = &adapter->hw;
> +	int ret;
> +
> +	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
> +
> +	while (test_and_set_bit(__PCH_GBE_RESETTING, &adapter->flags))
> +		msleep(1);

Don't invent your own mutex mechanism. Either use spin lock
or mutex.

-- 
