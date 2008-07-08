From: David Miller <davem@davemloft.net>
Subject: Re: Printing the driver name as part of the netdev watchdog message
Date: Tue, 08 Jul 2008 16:53:04 -0700 (PDT)
Message-ID: <20080708.165304.55424424.davem@davemloft.net>
References: <20080708144725.5b663d19@infradead.org>
	<20080708.145738.12692130.davem@davemloft.net>
	<20080708164826.2a2d52c2@infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: swise@opengridcomputing.com, rdreier@cisco.com,
	shemminger@vyatta.com, netdev@vger.kernel.org
To: arjan@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53308
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753523AbYGHXxF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 19:53:05 -0400
In-Reply-To: <20080708164826.2a2d52c2@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arjan van de Ven <arjan@infradead.org>
Date: Tue, 8 Jul 2008 16:48:26 -0700

> On Tue, 08 Jul 2008 14:57:38 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > What we need instead is to cache the info block into the netdev struct
> > when the driver is ->open()'d, and then you can fetch it out of
> > there however you like.
> 
> but.. isn't that like almost the same as using the object model data at
> that point?

You're right, this is getting silly

> I mean... if we had a "netdev_set_drivername()" thing with appropriate
> arguments (well I suck at names, name it whatever you feel like), we
> wouldn't need the drivers to implement each their own ethtool method,
> since this could just be done in one place and pull the data from the
> netdev.
> 
> (for the eeprom etc data that's different, but those are already
> different ethtool methods last I looked)

To be honest, the more I think about this, the driver->name should
be sufficient.

I just checked a bunch of PCI drivers and they provide the
same value for pci_driver->name as ethtool's info->driver

Sure, the ethtool info thing has a driver version etc. but
for your purposes that really doesn't add much.
