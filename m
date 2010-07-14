From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 NEXT 1/5] qlcnic: fix pause params setting
Date: Tue, 13 Jul 2010 23:09:09 -0700 (PDT)
Message-ID: <20100713.230909.104045607.davem@davemloft.net>
References: <1279086893-22523-1-git-send-email-amit.salecha@qlogic.com>
	<1279086893-22523-2-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	rajesh.borundia@qlogic.com
To: amit.salecha@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39838
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751248Ab0GNGIy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jul 2010 02:08:54 -0400
In-Reply-To: <1279086893-22523-2-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: amit.salecha@qlogic.com
Date: Tue, 13 Jul 2010 22:54:49 -0700

> From: Rajesh Borundia <rajesh.borundia@qlogic.com>
> 
> Turning off rx pause param and autoneg param is not supported so
> return error in that case.
> 
> Signed-off-by: Rajesh Borundia <rajesh.borundia@qlogic.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> ---
>  drivers/net/qlcnic/qlcnic_ethtool.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
> index baf5a52..8599993 100644
> --- a/drivers/net/qlcnic/qlcnic_ethtool.c
> +++ b/drivers/net/qlcnic/qlcnic_ethtool.c
> @@ -578,8 +578,13 @@ qlcnic_set_pauseparam(struct net_device *netdev,
>  		}
>  		QLCWR32(adapter, QLCNIC_NIU_GB_PAUSE_CTL, val);
>  	} else if (adapter->ahw.port_type == QLCNIC_XGBE) {
> +
> +		if (!pause->rx_pause || pause->autoneg)
> +			return -EOPNOTSUPP;

There is no reason to add an empty line at the beginning of this
code block, please remove it.
