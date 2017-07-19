From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH V2 net-next 20/21] net-next/hinic: Add ethtool and stats
Date: Wed, 19 Jul 2017 03:27:54 -0700
Message-ID: <1500460074.25934.33.camel@perches.com>
References: <cover.1500454998.git.aviad.krawczyk@huawei.com>
         <b66411dd204e8989f58e70bea8ae11d2cbe5cd1b.1500454998.git.aviad.krawczyk@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        bc.y@huawei.com, victor.gissin@huawei.com, zhaochen6@huawei.com,
        tony.qu@huawei.com
To: Aviad Krawczyk <aviad.krawczyk@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <b66411dd204e8989f58e70bea8ae11d2cbe5cd1b.1500454998.git.aviad.krawczyk@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-07-19 at 17:19 +0800, Aviad Krawczyk wrote:
> Add ethtool operations and statistics operations.

series trivia:

> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_main.c b/drivers/net/ethernet/huawei/hinic/hinic_main.c
[]
> @@ -67,6 +67,178 @@
[]
> +static int hinic_get_link_ksettings(struct net_device *netdev,
> +				    struct ethtool_link_ksettings
> +				    *link_ksettings)
> +{
[]
> +	err = hinic_port_get_cap(nic_dev, &port_cap);
> +	if (err) {
> +		dev_err(&netdev->dev, "Failed to get port capabilities\n");
> +		return err;
> +	}

it looks like a lot of these dev_<level> calls
should be converted to netdev_<level>

from:
		dev_err(&netdev->dev, ...);
to:
		netdev_err(netdev, ...);

etc...
