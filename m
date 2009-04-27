From: Chris Leech <christopher.leech@intel.com>
Subject: Re: [PATCH] netdev: storage address support
Date: Mon, 27 Apr 2009 15:28:00 -0700
Message-ID: <20090427222800.GA14396@cleech-lnx.jf.intel.com>
References: <20090424080349.30460.73770.stgit@localhost.localdomain> <20090427.030103.88777540.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-scsi-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090427.030103.88777540.davem@davemloft.net>
Sender: linux-scsi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Apr 27, 2009 at 03:01:03AM -0700, David Miller wrote:
> From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Date: Fri, 24 Apr 2009 01:03:50 -0700
> 
> > 2) Server Provided MAC Address (SPMA)
> > The server indicates to the FCF the address it would like to use for FCoE
> > traffic.  It's expected that SPMA capable interfaces will have a storage
> > dedicated MAC address programed into EPROM, flash, or other non-volatile
> > storage which the driver will be able to provide to the FCoE stack.
> > 
> > This adds a net_device_ops function to query a driver for a dedicated storage
> > address.
> > 
> > If ndo_get_storage_address is implemented, then the address will also be
> > exposed as a sysfs attribute.  In order to do that, a new optional attrs group
> > is added to the net_device, with the visibility of each attribute protected by
> > a call to netdev_show_optional_attr().
> 
> This should be what is currently provided in netdev->perm_addr[]
> 
> I really see no difference.

There seems to be some desire to use separate MAC address for LAN and
SAN traffic on a converged network, even when using the server provided
addressing mode for FCoE.  So I'm looking at a device that has an extra
MAC address in it's EEPROM, that's intended to be used for SAN traffic
only.

At first glance Jiri's "list of device addresses" patch seems to be
heading towards a more general approach to having multiple MAC
addresses, without providing any sort of intent on how they should be
used.  But given that it's trying to solve a bonding + bridging issue,
the addresses involved seem fairly dynamic and I'm not sure how it
differs much from the existing uc_list.

Ignoring the issue of intended use for the moment, if an ethernet driver
wanted to advertise several MAC addresses to the system how should it go
about that?

- Chris
