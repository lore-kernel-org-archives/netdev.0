From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3][NET] gen_estimator: faster gen_kill_estimator
Date: Mon, 21 Jan 2008 02:35:15 -0800 (PST)
Message-ID: <20080121.023515.256390630.davem@davemloft.net>
References: <20080120234659.GA2691@ami.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, slavon@bigtelecom.ru, kaber@trash.net,
	hadi@cyberus.ca
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40249
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758550AbYAUKfK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2008 05:35:10 -0500
In-Reply-To: <20080120234659.GA2691@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Mon, 21 Jan 2008 00:46:59 +0100

I like the technique you used to fix this bug, but:

> diff -Nurp 2.6.24-rc8-mm1-/include/linux/gen_stats.h 2.6.24-rc8-mm1+/include/linux/gen_stats.h
> --- 2.6.24-rc8-mm1-/include/linux/gen_stats.h	2007-10-09 22:31:38.000000000 +0200
> +++ 2.6.24-rc8-mm1+/include/linux/gen_stats.h	2008-01-20 20:37:08.000000000 +0100
> @@ -28,11 +28,13 @@ struct gnet_stats_basic
>   * struct gnet_stats_rate_est - rate estimator
>   * @bps: current byte rate
>   * @pps: current packet rate
> + * @gen_estimator: internal data
>   */
>  struct gnet_stats_rate_est
>  {
>  	__u32	bps;
>  	__u32	pps;
> +	unsigned long	gen_estimator;
>  };
>  
>  /**

Sorry, this structure is exported to userspace so we can't
change it like that.

It is an attribute passed over netlink sockets.

