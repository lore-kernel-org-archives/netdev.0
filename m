From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH v2 net-next 2/2] net: print net_device reg_state in
 netdev_* unless it's registered
Date: Thu, 17 Jul 2014 10:00:24 -0700
Message-ID: <1405616424.12363.47.camel@joe-AO725>
References: <1405606186-13703-1-git-send-email-vfalico@gmail.com>
	 <1405606186-13703-3-git-send-email-vfalico@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jason Baron <jbaron@akamai.com>,
	Eric Dumazet <edumazet@google.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	stephen hemminger <stephen@networkplumber.org>,
	Jerry Chu <hkchu@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0138.hostedemail.com ([216.40.44.138]:48162 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750813AbaGQRA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 13:00:28 -0400
In-Reply-To: <1405606186-13703-3-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-07-17 at 16:09 +0200, Veaceslav Falico wrote:
> This way we'll always know in what status the device is, unless it's
> running normally (i.e. NETDEV_REGISTERED).
[]
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
[]
> @@ -3388,6 +3388,20 @@ static inline const char *netdev_name(const struct net_device *dev)
>  	return dev->name;
>  }
>  
> +static inline const char *netdev_reg_state(const struct net_device *dev)
> +{
> +	switch (dev->reg_state) {
> +	case NETREG_UNINITIALIZED: return " (unregistered)";

Why not " (uninitialized)"?

> +	case NETREG_REGISTERED: return "";
> +	case NETREG_UNREGISTERING: return " (unregistering)";
> +	case NETREG_UNREGISTERED: return " (unregistered)";
> +	case NETREG_RELEASED: return " (released)";
> +	case NETREG_DUMMY: return " (dummy)";
> +	}
> +
> +	return " (unknown)";

Shouldn't this " (unknown)" have stronger text
and use a WARN_ON_ONCE?

I'd put this in net/core/dev.c and make it not be static inline.
