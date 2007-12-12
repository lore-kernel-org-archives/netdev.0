From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 3/4] ixp2000: rtnl_lock out of loop will be faster
Date: Wed, 12 Dec 2007 21:01:58 +0100
Message-ID: <20071212200158.GA2886@xi.wantstofly.org>
References: <475FA05C.1060705@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:56114 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751991AbXLLUCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2007 15:02:00 -0500
Content-Disposition: inline
In-Reply-To: <475FA05C.1060705@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 12, 2007 at 04:48:28PM +0800, Wang Chen wrote:

> [PATCH 3/4] [NETDEV] ixp2000: rtnl_lock out of loop will be faster
> 
> Before this patch, it gets and releases the lock at each
> iteration of the loop. Changing unregister_netdev to
> unregister_netdevice and locking outside of the loop will
> be faster for this approach.

Since the number of net devices is typically either 2 or 3 (depending
on the specific model card you're using), and this is not in any kind
of hot path at all, I don't see a whole lot of benefit of acquiring
the RTNL separately.  Besides, I'm slightly worried about putting
knowledge of the RTNL into the driver directly.
