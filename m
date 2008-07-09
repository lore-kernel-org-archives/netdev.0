From: Joe Perches <joe@perches.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Wed, 09 Jul 2008 10:20:55 -0700
Message-ID: <1215624055.5553.252.camel@localhost>
References: <20080708144725.5b663d19@infradead.org>
	 <20080708.145738.12692130.davem@davemloft.net>
	 <20080708164826.2a2d52c2@infradead.org>
	 <20080708.165304.55424424.davem@davemloft.net>
	 <20080708184456.52e94b93@infradead.org>  <20080708201658.2c496b6a@speedy>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Arjan van de Ven <arjan@infradead.org>,
	David Miller <davem@davemloft.net>,
	swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 136-022.dsl.labridge.com ([206.117.136.22]:1741 "EHLO
	mail.perches.com" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1750940AbYGIRZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 13:25:41 -0400
In-Reply-To: <20080708201658.2c496b6a@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-07-08 at 20:16 -0700, Stephen Hemminger wrote:
> > +void netdev_drivername(struct net_device *dev, char *buffer, int len)
> void netdev_drivername(const struct net_device *dev, char *buffer, int len)
> since net device not changed.

char *netdev_drivername(const struct net_dev *dev, char *buffer, size_t len)

size_t len and returns *buffer

allows:

	char drivername[64];
        printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed out\n",
               dev->name, netdev_drivername(dev, drivername, sizeof(drivername));


