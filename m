From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] netxen: write IP address to firmware when
	using bonding
Date: Wed, 23 Nov 2011 22:24:27 -0500
Message-ID: <20111124032426.GG25132@gospo.rdu.redhat.com>
References: <1322073791-15223-1-git-send-email-andy@greyhouse.net> <20111123.160922.1983654308126240492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andy@greyhouse.net, netdev@vger.kernel.org, sony.chacko@qlogic.com,
	rajesh.borundia@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751724Ab1KXDYc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Nov 2011 22:24:32 -0500
Content-Disposition: inline
In-Reply-To: <20111123.160922.1983654308126240492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 23, 2011 at 04:09:22PM -0500, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Wed, 23 Nov 2011 13:43:11 -0500
> 
> > The following patch was added to enable NX3031 devices to properly
> > aggregate frames for LRO:
> > 
> > 	commit 6598b169b856793f8f9b80a3f3c5a48f5eaf40e3
> > 	Author: Dhananjay Phadke <dhananjay@netxen.com>
> > 	Date:   Sun Jul 26 20:07:37 2009 +0000
> > 
> > 	    netxen: enable ip addr hashing
> > 
> > This patch is a followup to that fix as it allows LRO aggregation on
> > bonded devices that contain an NX3031 device.  This was tested on an
> > older distro and modified slightly to the latest upstream.
> > 
> > Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> 
> Let's put a helper function somewhere instead of expanding this sequence
> in every driver that might want to determine if it is a bonding slave.

Dave,

Are you talking about adding a macro like this:

	for_each_dev_in_bond(bond,slave) {
		[...]
	}

to replace the statements I added that were like this:

	for_each_netdev_rcu(&init_net, slave) {
		if (slave->master == dev) {
			[...]
		}
	}

If so, that totally seems reasonable.  If were requesting something
else, please let me know.

Thanks,

-andy
