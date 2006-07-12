From: Jiri Benc <jbenc@suse.cz>
Subject: Re: What's new in wireless-dev?
Date: Wed, 12 Jul 2006 11:48:32 +0200
Message-ID: <20060712114832.4f1dbac6@griffin.suse.cz>
References: <20060711204553.GB26186@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:19869 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750867AbWGLJsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jul 2006 05:48:35 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060711204553.GB26186@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 11 Jul 2006 16:45:58 -0400, John W. Linville wrote:
> John W. Linville:
>       d80211: use netif_tx_lock API

> --- a/net/d80211/ieee80211.c
> +++ b/net/d80211/ieee80211.c
> @@ -1338,7 +1338,7 @@ static void ieee80211_tx_pending(unsigne
>  	struct ieee80211_txrx_data tx;
>  	int i, ret, reschedule = 0;
>  
> -	spin_lock_bh(&dev->xmit_lock);
> +	netif_tx_lock_bh(dev);
>  	dev->xmit_lock_owner = smp_processor_id();

Those dev->xmit_lock_owner assignments are done in netif_tx_[un]lock_bh,
so they should go away as well.

 Jiri

-- 
Jiri Benc
SUSE Labs
