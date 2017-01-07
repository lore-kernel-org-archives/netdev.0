From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v6 0/3] net: dummy: Introduce dummy virtual
 functions
Date: Fri, 06 Jan 2017 20:38:04 -0500 (EST)
Message-ID: <20170106.203804.2023763441703979123.davem@davemloft.net>
References: <20170105190913.29986-1-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: phil@nwl.cc
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49232 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755425AbdAGBiJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 20:38:09 -0500
In-Reply-To: <20170105190913.29986-1-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Phil Sutter <phil@nwl.cc>
Date: Thu,  5 Jan 2017 20:09:10 +0100

> This series adds VF support to dummy device driver after adding the
> necessary infrastructure changes:
> 
> Patch 1 adds a netdevice callback for device-specific VF count
> retrieval. Patch 2 then changes dev_num_vf() implementation to make use
> of that new callback (if implemented), falling back to the old
> behaviour. Patch 3 then implements VF support in dummy, without the fake
> PCI parent device hack from v5.

Please don't make this a netdev specific method and interface.

Put the method in "struct bus_device", thereby making it a generic
"device" layer thing.

So the pci BUS type will implement pci_bus_type.num_vf().  And you'll
make a bus type for the dummy device to attach to which will implement
it's own.
