From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: New commands to configure IOV features
Date: Fri, 20 Jul 2012 21:01:13 +0100
Message-ID: <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>
			<5005D45D.1040302@genband.com>
		 <20120717.141153.46613285253481776.davem@davemloft.net>
		 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>
	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	 <5009B186.6000806@genband.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Don Dutile <ddutile@redhat.com>,
	David Miller <davem@davemloft.net>, <yuvalmin@broadcom.com>,
	<gregory.v.rose@intel.com>, <netdev@vger.kernel.org>,
	<linux-pci@vger.kernel.org>
To: Chris Friesen <chris.friesen@genband.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <5009B186.6000806@genband.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2012-07-20 at 13:29 -0600, Chris Friesen wrote:
> On 07/20/2012 11:42 AM, Ben Hutchings wrote:
> >
> > The ethtool API is typically used for net device operations that can be
> > largely devolved to individual drivers, and which the network stack can
> > mostly ignore (though offload features are an historical exception to
> > this).  It started with Ethernet link settings, but many operations are
> > applicable (and implemented by) other types of network device.
> 
> That (potentially) accounts for all network devices, but it leaves all 
> the other devices that could export virtual functions.
> 
> Why should I need to use a different API to enable virtual functions on 
> my network device and my storage controller?

Indeed; I was merely making the point that it would be quite valid to
use that means for setting VF network parameters for any network device
that supports IOV.

> (And why should "ethtool" or "ip" care that it's a virtual function?)

VFs may be assigned to a guest which is not fully trusted by the
hypervisor or privileged domain.  (This can sometimes be true for PFs
too, depending on the capabilities of the hypervisor and guest OS.)
Some configuration may therefore need to be done via a trusted PF.

> What Don and I are suggesting is that the concept of virtual functions 
> is a PCI thing, so it should be dealt with at the PCI layer.  Regardless 
> of the type of device the export of virtual functions is conceptually 
> the same thing, so it should use the same API.
> 
> Once the device exists, then domain-specific APIs would be used to 
> configure it the same way that they would configure a physical device.

To an extent, but not entirely.

Currently, the assigned MAC address and (optional) VLAN tag for each
networking VF are configured via the PF net device (though this is done
though the rtnetlink API rather than ethtool).

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
