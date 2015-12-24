From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] ip_tunnel: Move stats update to
 iptunnel_xmit()
Date: Wed, 23 Dec 2015 21:57:12 -0500 (EST)
Message-ID: <20151223.215712.2108576072504626201.davem@davemloft.net>
References: <1450914723-16452-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nicolas.dichtel@6wind.com
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40563 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751683AbbLXDDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 22:03:48 -0500
In-Reply-To: <1450914723-16452-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin B Shelar <pshelar@nicira.com>
Date: Wed, 23 Dec 2015 15:52:03 -0800

>  	} else {
> -		err_stats->tx_dropped++;
> +		struct net_device_stats *err_stats = &dev->stats;
> +
> +		if (err < 0) {
> +			err_stats->tx_errors++;
> +			err_stats->tx_aborted_errors++;
> +		} else {
> +			err_stats->tx_dropped++;
> +		}

The original code did not have this "tx_dropped" code path
and you aren't explaining in your commit message why you
are adding this new behavior.
