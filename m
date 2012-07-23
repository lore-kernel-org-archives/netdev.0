From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: New commands to configure IOV features
Date: Mon, 23 Jul 2012 18:40:51 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A070C7D9DCD@ORSMSX106.amr.corp.intel.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>
	<5005D45D.1040302@genband.com>
	<20120717.141153.46613285253481776.davem@davemloft.net>
	<500978C7.5050004@genband.com>	<50097FBD.9080202@redhat.com>
	<1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	<5009B186.6000806@genband.com>
	<1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
	<5009ECDF.4090305@genband.com>	<500D59BF.9040006@redhat.com>
	<500D6932.8090306@genband.com>
 <20120723113607.56ce7aaf@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Don Dutile <ddutile@redhat.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"yuvalmin@broadcom.com" <yuvalmin@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>,
	Chris Friesen <chris.friesen@genband.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:52589 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754422Ab2GWSkx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 14:40:53 -0400
In-Reply-To: <20120723113607.56ce7aaf@nehalam.linuxnetplumber.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Stephen Hemminger [mailto:shemminger@vyatta.com]
> Sent: Monday, July 23, 2012 11:36 AM
> To: Chris Friesen
> Cc: Don Dutile; Ben Hutchings; David Miller; yuvalmin@broadcom.com; Rose,
> Gregory V; netdev@vger.kernel.org; linux-pci@vger.kernel.org
> Subject: Re: New commands to configure IOV features
> 
> On Mon, 23 Jul 2012 09:09:38 -0600
> Chris Friesen <chris.friesen@genband.com> wrote:
> 
> > On 07/23/2012 08:03 AM, Don Dutile wrote:
> > > On 07/20/2012 07:42 PM, Chris Friesen wrote:
> > >>
> > >> I actually have a use-case where the guest needs to be able to
> > >> modify the MAC addresses of network devices that are actually VFs.
> > >>
> > >> The guest is bonding the network devices together, so the bonding
> > >> driver in the guest expects to be able to set all the slaves to the
> > >> same MAC address.
> > >>
> > >> As I read the ixgbe driver, this should be possible as long as the
> > >> host hasn't explicitly set the MAC address of the VF. Is that
> correct?
> > >>
> > >> Chris
> > >
> > > Interesting tug of war: hypervisors will want to set the macaddrs
> > > for security reasons,
> > >                         some guests may want to set macaddr for
> > > (valid?) config reasons.
> > >
> >
> > In our case we have control over both guest an host anyways, so it's
> > less of a security issue.  In the general case though I could see it
> > being an interesting problem.
> >
> > Back to the original discussion though--has anyone got any ideas about
> > the best way to trigger runtime creation of VFs?  I don't know what
> > the binary APIs looks like, but via sysfs I could see something like
> >
> > echo number_of_new_vfs_to_create >
> > /sys/bus/pci/devices/<address>/create_vfs
> >
> > Something else that occurred to me--is there buy-in from driver
> > maintainers?  I know the Intel ethernet drivers (what I'm most
> > familiar
> > with) would need to be substantially modified to support on-the-fly
> > addition of new vfs.  Currently they assume that the number of vfs is
> > known at module init time.
> >
> 
> Why couldn't rtnl_link_ops be used for this. It is already the preferred
> interface to create vlan's, bond devices, and other virtual devices?
> The one issue is that do the created VF's exist in kernel as devices or
> only visible to guest?

I would say that rtnl_link_ops are network oriented and not appropriate for something like a storage controller or graphics device, which are two other common SR-IOV capable devices.

I think it should be oriented toward the PCIe interface and subsystems in the kernel.

- Greg
