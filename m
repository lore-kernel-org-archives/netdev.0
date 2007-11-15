From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] via-velocity: don't oops on MTU change.
Date: Thu, 15 Nov 2007 09:26:00 +0100
Message-ID: <20071115082600.GA2366@ff.dom.local>
References: <20071114193844.0cab5c7d@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S\. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	jnelson-kernel-bugzilla@jamponi.net
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:35010 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751753AbXKOIVx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Nov 2007 03:21:53 -0500
Content-Disposition: inline
In-Reply-To: <20071114193844.0cab5c7d@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 15-11-2007 04:38, Stephen Hemminger wrote:
> Simple mtu change when device is down.
> Fix http://bugzilla.kernel.org/show_bug.cgi?id=9382.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
> 
> 
> --- a/drivers/net/via-velocity.c	2007-10-22 09:38:11.000000000 -0700
> +++ b/drivers/net/via-velocity.c	2007-11-14 19:34:30.000000000 -0800
> @@ -1963,6 +1963,11 @@ static int velocity_change_mtu(struct ne
>  		return -EINVAL;
>  	}
>  
> +	if (!netif_running(dev)) {
> +		dev->mtu = new_mtu;
> +		return 0;
> +	}
> +
>  	if (new_mtu != oldmtu) {
>  		spin_lock_irqsave(&vptr->lock, flags);

Shouldn't this latter 'if' be removed now, btw?

Regards,
Jarek P.
