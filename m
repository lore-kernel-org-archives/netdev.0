From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [patch net-next V4] net: introduce ethernet teaming device
Date: Mon, 24 Oct 2011 20:02:33 -0400
Message-ID: <20111025000232.GC20605@gospo.rdu.redhat.com>
References: <1319444005-1281-1-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, andy@greyhouse.net,
	tgraf@infradead.org, ebiederm@xmission.com, mirqus@gmail.com,
	kaber@trash.net, greearb@candelatech.com, jesse@nicira.com,
	fbl@redhat.com, benjamin.poirier@gmail.com, jzupka@redhat.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19692 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755774Ab1JYACy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Oct 2011 20:02:54 -0400
Content-Disposition: inline
In-Reply-To: <1319444005-1281-1-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 24, 2011 at 10:13:25AM +0200, Jiri Pirko wrote:
> This patch introduces new network device called team. It supposes to be
> very fast, simple, userspace-driven alternative to existing bonding
> driver.
> 
> Userspace library called libteam with couple of demo apps is available
> here:
> https://github.com/jpirko/libteam
> Note it's still in its dipers atm.
> 
> team<->libteam use generic netlink for communication. That and rtnl
> suppose to be the only way to configure team device, no sysfs etc.
> 
> Python binding basis for libteam was recently introduced (some need
> still need to be done on it though). Daemon providing arpmon/miimon
> active-backup functionality will be introduced shortly.
> All what's necessary is already implemented in kernel team driver.
> 
> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
> 
> v3->v4:
> 	- remove redundant synchronize_rcu from __team_change_mode()
> 	- revert "set and clear of mode_ops happens per pointer, not per
> 	  byte"
> 	- extend comment of function __team_change_mode()
> 
> v2->v3:
> 	- team_change_mtu() user rcu version of list traversal to unwind
> 	- set and clear of mode_ops happens per pointer, not per byte
> 	- port hashlist changed to be embedded into team structure
> 	- error branch in team_port_enter() does cleanup now
> 	- fixed rtln->rtnl
> 
> v1->v2:
> 	- modes are made as modules. Makes team more modular and
> 	  extendable.
> 	- several commenters' nitpicks found on v1 were fixed
> 	- several other bugs were fixed.
> 	- note I ignored Eric's comment about roundrobin port selector
> 	  as Eric's way may be easily implemented as another mode (mode
> 	  "random") in future.

Jiri,

I've been following this work closely since your first post and now to
wonder if you could create a 'team' tree somewhere.  It would be nice if
there was a repo that we could clone for testing and a base for others
to help with the development and provide patches.

It also might avoid so much of this back and forth, so that you are not
on v37 by the time the code meets everyones needs. :-)

Once the code goes mainline and Dave pulls your tree, you could then
remove it.

-andy
