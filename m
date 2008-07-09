From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Wed, 9 Jul 2008 19:28:50 +0100
Message-ID: <20080709182849.GM28029@solarflare.com>
References: <20080708144725.5b663d19@infradead.org> <20080708.145738.12692130.davem@davemloft.net> <20080708164826.2a2d52c2@infradead.org> <20080708.165304.55424424.davem@davemloft.net> <20080708184456.52e94b93@infradead.org> <20080708201658.2c496b6a@speedy> <1215624055.5553.252.camel@localhost> <20080709105631.492f86bd@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: Arjan van de Ven <arjan@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.mbr-roch.zen.net.uk ([212.23.3.140]:51003 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753218AbYGIS3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 14:29:01 -0400
Content-Disposition: inline
In-Reply-To: <20080709105631.492f86bd@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Arjan van de Ven wrote:
> On Wed, 09 Jul 2008 10:20:55 -0700
> Joe Perches <joe@perches.com> wrote:
> 
> > On Tue, 2008-07-08 at 20:16 -0700, Stephen Hemminger wrote:
> > > > +void netdev_drivername(struct net_device *dev, char *buffer, int
> > > > len)
> > > void netdev_drivername(const struct net_device *dev, char *buffer,
> > > int len) since net device not changed.
> > 
> > char *netdev_drivername(const struct net_dev *dev, char *buffer,
> > size_t len)
> > 
> > size_t len and returns *buffer
> > 
> > allows:
> > 
> > 	char drivername[64];
> >         printk(KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit timed
> > out\n", dev->name, netdev_drivername(dev, drivername,
> > sizeof(drivername));
> 
> I like the return a char * (updated patch below)
> I don't like the size_t... size_t is an abstraction to deal with file
> sizes.... but there's nothing else wrong with using an int for numbers.
[...]

size_t is for memory sizes - that's why sizeof() expressions have that
type.  File sizes are loff_t.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
