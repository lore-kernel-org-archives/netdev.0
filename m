From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 1/1] bonding: eliminate RTNL assertion spew
Date: Tue, 9 Jan 2007 18:34:58 -0500
Message-ID: <20070109233457.GB11755@gospo.rdu.redhat.com>
References: <20070109225900.GA11755@gospo.rdu.redhat.com> <45A421B3.4020301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, fubar@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:49232 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932532AbXAIXfJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jan 2007 18:35:09 -0500
To: Jeff Garzik <jeff@garzik.org>
Content-Disposition: inline
In-Reply-To: <45A421B3.4020301@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 09, 2007 at 06:13:55PM -0500, Jeff Garzik wrote:
> Andy Gospodarek wrote:
> >-void bond_alb_handle_active_change(struct bonding *bond, struct slave 
> >*new_slave)
> >+void bond_alb_handle_active_change(struct bonding *bond, struct slave 
> >*new_slave, int rtnl_locked)
> > {
> > 	struct slave *swap_slave;
> > 	int i;
> 
> Although this is not a direct NAK (haven't read the full patch yet), 
> conditional locking behavior like this is /very/ fragile, and in Linux 
> is generally discouraged.  Vendor drivers in particular have a history 
> of constantly getting this wrong, and it makes locking more difficult to 
> review.
> 
> 	Jeff
> 

I'd be happy to propose something that doesn't do conditional locking
like this.  I saw this route as a way to take the rtnl lock only when it
was absolutely necessary.  After spending some time trying to get it
right I can understand why it is so discouraged.  I'd also rather not
provide a 'bad example' for how to do things. :-)

If others are OK with it, I'd be happy to propose a patch like Stephen
suggested where the lock is taken in the mii/arp monitor routines.
Though the locking would be unnecessary in some cases it would be much
cleaner and easier to maintain.

