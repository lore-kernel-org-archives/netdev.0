From: David Miller <davem@davemloft.net>
Subject: Re: [net-next.git 3/8 (V2)] stmmac: add the initial tx coalesce
 schema
Date: Thu, 13 Sep 2012 16:23:33 -0400 (EDT)
Message-ID: <20120913.162333.1518469374321928795.davem@davemloft.net>
References: <1347346514-23411-1-git-send-email-peppe.cavallaro@st.com>
	<1347346514-23411-4-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: peppe.cavallaro@st.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49100 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932273Ab2IMUXf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 16:23:35 -0400
In-Reply-To: <1347346514-23411-4-git-send-email-peppe.cavallaro@st.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Date: Tue, 11 Sep 2012 08:55:09 +0200

> +	unsigned long flags;
> +
> +	spin_lock_irqsave(&priv->tx_lock, flags);
>  
> -	spin_lock(&priv->tx_lock);
> +	priv->xstats.tx_clean++;

You are changing the locking here for the sake of the new timer.

But timers run in software interrupt context, so this change is
completely unnecessary since NAPI runs in software interrupt context
as well, and neither timers nor NAPI run in hardware interrupts
context.

Therefore, disabling hardware interrupts for this lock is unnecessary
and will decrease performance.
