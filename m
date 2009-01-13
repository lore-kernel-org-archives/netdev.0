From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -net-next 3/4] firmware: convert tg3 driver to
 request_firmware()
Date: Mon, 12 Jan 2009 16:10:54 -0800 (PST)
Message-ID: <20090112.161054.180487472.davem@davemloft.net>
References: <20090105.160112.119906029.davem@davemloft.net>
	<20090107031724.GA6118@porter.dyn.128.marineau.org>
	<20090107230624.GA6894@porter.dyn.128.marineau.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: oliver@hartkopp.net, jaswinder@infradead.org, jgarzik@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-next@vger.kernel.org, mchan@broadcom.com
To: mike@marineau.org
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090107230624.GA6894@porter.dyn.128.marineau.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michael Marineau <mike@marineau.org>
Date: Wed, 7 Jan 2009 18:06:25 -0500

> -static void rfc2863_policy(struct net_device *dev)
> -{
> -	unsigned char operstate = default_operstate(dev);
> -
> -	if (operstate == dev->operstate)
> -		return;
> -
> -	write_lock_bh(&dev_base_lock);
> -
> -	switch(dev->link_mode) {
> -	case IF_LINK_MODE_DORMANT:
> -		if (operstate == IF_OPER_UP)
> -			operstate = IF_OPER_DORMANT;
> -		break;
> -
> -	case IF_LINK_MODE_DEFAULT:
> -	default:
> -		break;
> -	}
> -
> -	dev->operstate = operstate;
> -
> -	write_unlock_bh(&dev_base_lock);
> +	if (dev->link_mode == IF_LINK_MODE_DORMANT && netif_oper_up(dev))
> +		netif_userspace_dormant_on(dev);
> +	else
> +		netif_userspace_dormant_off(dev);
>  }

Michael, this doesn't work.

The whole point of taking the dev_base_lock is to freeze the state of
->link_mode, so that we can make a decision atomically based upon it's
value and without that value changing in the middle of the decision.
