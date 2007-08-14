From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: BUG: when using 'brctl stp'
Date: Tue, 14 Aug 2007 15:18:22 +0200
Message-ID: <20070814131822.GA13676@xi.wantstofly.org>
References: <46BCE380.60508@cluded.net> <20070812012037.0195b610.akpm@linux-foundation.org> <20070814141105.0a4b8dde@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@linux-foundation.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:55038 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750706AbXHNNS0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 09:18:26 -0400
Content-Disposition: inline
In-Reply-To: <20070814141105.0a4b8dde@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 14, 2007 at 02:11:05PM +0100, Stephen Hemminger wrote:

> Bridge locking for /sys/class/net/br0/bridge/stp_enabled
> was wrong.  Another bug in bridge utilities makes it such that
> this interface, meant it wasn't being used.  The locking needs
> to be removed from set_stp_state(), the lock is already acquired
> down in br_stp_start()/br_stp_stop.

The 'locking' in set_stp_state() is actually dropping the lock
around the br_stp_set_enabled() invocation, not acquiring it:


> @@ -150,9 +150,7 @@ static ssize_t show_stp_state(struct dev
>  static void set_stp_state(struct net_bridge *br, unsigned long val)
>  {
>  	rtnl_lock();
> -	spin_unlock_bh(&br->lock);
>  	br_stp_set_enabled(br, val);
> -	spin_lock_bh(&br->lock);
>  	rtnl_unlock();
>  }
