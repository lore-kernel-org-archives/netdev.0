From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFC PATCH 5/5] geneve: add initial netdev driver for GENEVE
 tunnels
Date: Fri, 3 Apr 2015 14:31:27 -0400
Message-ID: <20150403183126.GB22162@tuxdriver.com>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
 <1428002227-11636-6-git-send-email-linville@tuxdriver.com>
 <20150402202002.GG2613@nanopsycho.orion>
 <20150403145711.GD31348@tuxdriver.com>
 <20150403150744.GE31348@tuxdriver.com>
 <20150403152053.GF16847@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35058 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752209AbbDCSpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Apr 2015 14:45:15 -0400
Content-Disposition: inline
In-Reply-To: <20150403152053.GF16847@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 03, 2015 at 05:20:53PM +0200, Jiri Pirko wrote:
> Fri, Apr 03, 2015 at 05:07:44PM CEST, linville@tuxdriver.com wrote:
> >On Fri, Apr 03, 2015 at 10:57:12AM -0400, John W. Linville wrote:
> >> On Thu, Apr 02, 2015 at 10:20:02PM +0200, Jiri Pirko wrote:
> >> > Thu, Apr 02, 2015 at 09:17:06PM CEST, linville@tuxdriver.com wrote:
> >> > >This is an initial implementation of a netdev driver for GENEVE
> >> > >tunnels.  This implementation uses a fixed UDP port, and only supports
> >> > >a single tunnel (and therefore only a single VNI) per net namespace.
> >> > >Only IPv4 links are supported at this time.
> >> > 
> >> > 
> >> > Thanks for doing this John!
> >> > 
> >> > 
> >> > >
> >> > >Signed-off-by: John W. Linville <linville@tuxdriver.com>
> >> > >---
> >> > > drivers/net/Kconfig          |  14 ++
> >> > > drivers/net/Makefile         |   1 +
> >> > > drivers/net/geneve.c         | 451 +++++++++++++++++++++++++++++++++++++++++++
> >> > > include/uapi/linux/if_link.h |   9 +
> >> > > 4 files changed, 475 insertions(+)
> >> > > create mode 100644 drivers/net/geneve.c
> >> > >
> >> > 
> >> > ...
> >> > 
> >> > >+/* Initialize the device structure. */
> >> > >+static void geneve_setup(struct net_device *dev)
> >> > >+{
> >> > >+	struct geneve_dev *geneve = netdev_priv(dev);
> >> > >+
> >> > >+	ether_setup(dev);
> >> > >+
> >> > >+	dev->netdev_ops = &geneve_netdev_ops;
> >> > >+	dev->destructor = free_netdev;
> >> > >+	SET_NETDEV_DEVTYPE(dev, &geneve_type);
> >> > >+
> >> > >+	INIT_WORK(&geneve->sock_work, geneve_sock_work);
> >> > 
> >> > I would push work initialization into geneve_newlink. Seems odd to have
> >> > it here in setup.
> >> 
> >> Yes, that will probably work a lot better for multiple tunnels on a
> >> host... :-)
> >
> >Ignore that comment -- I was thinking...something else...need coffee... ;-)
> >
> >What makes newlink better for INIT_WORK than setup?
> 
> 
> Can be here for sure. I just thought that setup should setup netdev
> according to type. This is not it. This initializes a part of priv
> structure.

Ah -- I wasn't thinking about it that way.  I'll consider it. :-)

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
