From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/7] : tehuti Fix possible causing oops of
 net_rx_action
Date: Wed, 12 Dec 2007 07:18:32 -0800 (PST)
Message-ID: <20071212.071832.07747779.davem@davemloft.net>
References: <002901c83c73$b089b6e0$9c94fea9@jason>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, baum@tehutinetworks.net, andy@greyhouse.net
To: joonwpark81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60561
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752042AbXLLPSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 10:18:35 -0500
In-Reply-To: <002901c83c73$b089b6e0$9c94fea9@jason>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Joonwoo Park" <joonwpark81@gmail.com>
Date: Wed, 12 Dec 2007 13:01:27 +0900

> @@ -305,6 +305,8 @@ static int bdx_poll(struct napi_struct *napi, int budget)
>  
>  		netif_rx_complete(dev, napi);
>  		bdx_enable_interrupts(priv);
> +		if (unlikely(work_done == napi->weight))
> +			return work_done - 1;
>  	}
>  	return work_done;
>  }

Any time your trying to make a caller "happy" by adjusting
a return value forcefully, it's a hack.

And I stated this in another reply about this issue.

Please do not fix the problem this way.

The correct way to fix this is, if we did process a full
"weight" or work, we should not netif_rx_complete() and
we should not re-enable chip interrupts.

Instead we should return the true "work_done" value and
allow the caller to thus poll us one more time.
