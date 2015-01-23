From: Erik Hugne <erik.hugne@ericsson.com>
Subject: Re: [PATCH net-next 1/2] tipc: fix excessive network event logging
Date: Fri, 23 Jan 2015 07:44:30 +0100
Message-ID: <20150123064430.GA26059@haze>
References: <1421943032-29924-1-git-send-email-erik.hugne@ericsson.com>
 <1421947487.2702.1.camel@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <richard.alpe@ericsson.com>, <netdev@vger.kernel.org>,
	<jon.maloy@ericsson.com>, <ying.xue@windriver.com>,
	<tipc-discussion@lists.sourceforge.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg23.ericsson.net ([193.180.251.37]:52611 "EHLO
	sesbmg23.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750996AbbAWGqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 01:46:15 -0500
Content-Disposition: inline
In-Reply-To: <1421947487.2702.1.camel@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 22, 2015 at 09:24:47AM -0800, Joe Perches wrote:
> On Thu, 2015-01-22 at 17:10 +0100, erik.hugne@ericsson.com wrote:
> > From: Erik Hugne <erik.hugne@ericsson.com>
> > 
> > If a large number of namespaces is spawned on a node and TIPC is
> > enabled in each of these, the excessive printk tracing of network
> > events will cause the system to grind down to a near halt.
> > The traces are still of debug value, so instead of removing them
> > completely we fix it by changing the link state and node availability
> > logging debug traces.
> 
> Maybe some of these should be net_<level>_ratelimited(fmt, ...)

We proposed that initially, but changed all to pr_debug after David's comment:
http://www.spinics.net/lists/netdev/msg312902.html
The topology information (links going up/down) can be accessed
both via netlink ('tipc link list' command) and the topology server
via a subscription API.

//E
