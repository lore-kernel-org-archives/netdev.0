From: Matt Mackall <mpm@selenic.com>
Subject: Re: [PATCH -mm 5/9] netconsole: Introduce dev_status member
Date: Wed, 4 Jul 2007 08:56:42 -0500
Message-ID: <20070704135642.GB11115@waste.org>
References: <20070704110739.28520.5036.sendpatchset@cselinux1.cse.iitk.ac.in> <20070704110804.28520.25792.sendpatchset@cselinux1.cse.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keiichi Kii <k-keiichi@bx.jp.nec.com>,
	Netdev <netdev@vger.kernel.org>,
	Joel Becker <joel.becker@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>
To: Satyam Sharma <ssatyam@cse.iitk.ac.in>
Return-path: <netdev-owner@vger.kernel.org>
Received: from waste.org ([66.93.16.53]:49038 "EHLO waste.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758188AbXGDN5w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jul 2007 09:57:52 -0400
Content-Disposition: inline
In-Reply-To: <20070704110804.28520.25792.sendpatchset@cselinux1.cse.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 04, 2007 at 04:38:04PM +0530, Satyam Sharma wrote:
> From: Satyam Sharma <ssatyam@cse.iitk.ac.in>
> 
> [5/9] netconsole: Introduce dev_status member
> 
> Introduce a new member in netconsole_target that tracks the status (up or
> down) of the underlying interface network device that the specific logging
> target netpoll is attached to.
> 
> We then join this up with the just-introduced net_device notifier, and
> introduce NETDEV_UP and NETDEV_DOWN notifications. By disabling the target
> when the corresponding local interface is down, we save the overhead of
> unnecessarily disabling interrupts and calling into the netpoll stack in
> console->write().

Yuck. 

> +/*
> + * Why no net_dev_is_up() in netdevice.h? The kernel could lose a lot of
> + * weight if only netdevice.h had the good sense to export such a function.
> + * Oh well ...
> + */
> +static inline int net_dev_is_up(struct net_device *net_dev)
> +{
> +	return ((net_dev->flags & IFF_UP) == IFF_UP);
> +}

Why editorialize? Why not just add this to netdevice.h?

> +	if (nt->dev_status) {

Why not simply call net_dev_is_up?

-- 
Mathematics is the supreme nostalgia of our time.
