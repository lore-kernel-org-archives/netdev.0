From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2] forcedeth: Allow ethtool to enable/disable loopback.
Date: Sun, 08 May 2011 15:57:59 -0700 (PDT)
Message-ID: <20110508.155759.200382648.davem@davemloft.net>
References: <1304472127-652-1-git-send-email-maheshb@google.com>
	<1304559400-16257-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com
To: maheshb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49735
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932374Ab1EHW6b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 May 2011 18:58:31 -0400
In-Reply-To: <1304559400-16257-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>
Date: Wed,  4 May 2011 18:36:40 -0700

> @@ -4502,6 +4549,9 @@ static int nv_set_features(struct net_device *dev, u32 features)
>  
>  		spin_unlock_irq(&np->lock);
>  	}
> +	if ((changed & NETIF_F_LOOPBACK) && netif_running(dev)) {
> +		nv_set_loopback(dev, features);
> +	}
>  

Please do not create a braced basic block just for a single
line of code.  Simply:

> +	if ((changed & NETIF_F_LOOPBACK) && netif_running(dev))
> +		nv_set_loopback(dev, features);

is sufficient.
