From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] Gigabit Ethernet driver of Topcliff PCH
Date: Thu, 26 Aug 2010 08:40:22 -0700
Message-ID: <20100826084022.457ac967@nehalam>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C763A67.5040107@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Aug 2010 18:56:55 +0900
Masayuki Ohtake <masa-korg@dsn.okisemi.com> wrote:

> +static int pch_gbe_get_settings(struct net_device *netdev,
> +				 struct ethtool_cmd *ecmd)
> +{
> +	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
> +	int ret;
> +
> +	PCH_GBE_DEBUG("ethtool: %s\n", __func__);
> +
> +	ret = mii_ethtool_gset(&adapter->mii, ecmd);
> +	ecmd->supported &= (u32) (~SUPPORTED_TP);
> +	ecmd->supported &= (u32) (~SUPPORTED_1000baseT_Half);
> +	ecmd->advertising &= (u32) (~ADVERTISED_TP);
> +	ecmd->advertising &= (u32) (~ADVERTISED_1000baseT_Half);
> +
> +	if (netif_carrier_ok(adapter->netdev)) {
> +		;
> +	} else {
> +		ecmd->speed = 0xFFFF;
> +		ecmd->duplex = 0xFF;
> +	}
> +	return ret;
> +}

No need for cast to u32 on the masking:
        ecmd->supported &= ~(SUPPORTED_TP | SUPPORTED_1000baseT_Half);
	ecmd->advertising &= ~(ADVERTISED_TP | ADVERTISED_1000baseT_Half);



Awkward use of if, and don't set other bits in duplex
       if (!netif_carrier_ok(adapter->netdev))
                ecmd->speed = -1;
            

-- 
