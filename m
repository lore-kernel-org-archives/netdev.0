From: Phil Sutter <phil@nwl.cc>
Subject: Re: [net-next PATCH v6 0/3] net: dummy: Introduce dummy virtual
 functions
Date: Fri, 13 Jan 2017 13:09:55 +0100
Message-ID: <20170113120955.GJ6774@orbyte.nwl.cc>
References: <20170105190913.29986-1-phil@nwl.cc>
 <20170106.203804.2023763441703979123.davem@davemloft.net>
 <20170111133857.GA10974@orbyte.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:56645 "EHLO mail.nwl.cc"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752026AbdAMMJ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 07:09:56 -0500
Content-Disposition: inline
In-Reply-To: <20170111133857.GA10974@orbyte.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 11, 2017 at 02:38:57PM +0100, Phil Sutter wrote:
> On Fri, Jan 06, 2017 at 08:38:04PM -0500, David Miller wrote:
> > From: Phil Sutter <phil@nwl.cc>
> > Date: Thu,  5 Jan 2017 20:09:10 +0100
> > 
> > > This series adds VF support to dummy device driver after adding the
> > > necessary infrastructure changes:
> > > 
> > > Patch 1 adds a netdevice callback for device-specific VF count
> > > retrieval. Patch 2 then changes dev_num_vf() implementation to make use
> > > of that new callback (if implemented), falling back to the old
> > > behaviour. Patch 3 then implements VF support in dummy, without the fake
> > > PCI parent device hack from v5.
> > 
> > Please don't make this a netdev specific method and interface.
> > 
> > Put the method in "struct bus_device", thereby making it a generic
> > "device" layer thing.
> > 
> > So the pci BUS type will implement pci_bus_type.num_vf().  And you'll
> > make a bus type for the dummy device to attach to which will implement
> > it's own.
> 
> Following your approach, I'm running into a weird issue with conflicting
> sysfs symlink names after calling register_netdevice for the dummy
> device which has dev->dev.bus set to the dummy bus type I introduced:
> 
> In netdev_register_kobject, dev->class is set to &net_class. This means
> that later in device_add, the call to device_add_class_symlinks will
> create symlink to the class named devices/virtual/net/dummy0/subsystem.
> 
> The following call to bus_add_device by device_add though tries to
> create a symlink to the bus with identical name.

Ah, nevermind - it's actually the netdev's parent which should have the
bus type set. At first I assumed this would be a PCI specific thing.

Thanks, Phil
