From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pch_gbe: Fix the issue which a driver locks when rx
 offload is set by ethtool
Date: Tue, 08 Feb 2011 16:40:30 -0800 (PST)
Message-ID: <20110208.164030.242137610.davem@davemloft.net>
References: <4D512A27.2030406@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tomoya-linux@dsn.okisemi.com,
	qi.wang@intel.com, yong.y.wang@intel.com,
	andrew.chih.howe.khor@intel.com, joel.clark@intel.com,
	kok.howg.ewe@intel.com, linux-kernel@vger.kernel.org
To: toshiharu-linux@dsn.okisemi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D512A27.2030406@dsn.okisemi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Toshiharu Okada <toshiharu-linux@dsn.okisemi.com>
Date: Tue, 08 Feb 2011 20:33:59 +0900

> @@ -531,12 +533,8 @@ void pch_gbe_reinit_locked(struct pch_gbe_adapter *adapter)
>  {
>  	struct net_device *netdev = adapter->netdev;
>  
> -	rtnl_lock();
> -	if (netif_running(netdev)) {
> -		pch_gbe_down(adapter);
> -		pch_gbe_up(adapter);
> -	}
> -	rtnl_unlock();
> +	pch_gbe_down(adapter);
> +	pch_gbe_up(adapter);

Are you sure you can just blindly delete the netif_running() check here?
