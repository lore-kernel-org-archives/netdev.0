From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: New commands to configure IOV features
Date: Mon, 23 Jul 2012 16:37:21 +0000
Message-ID: <C5551D9AAB213A418B7FD5E4A6F30A070C7D873D@ORSMSX106.amr.corp.intel.com>
References: <5003DC9B.8000706@broadcom.com>	<5005BD00.4090106@redhat.com>
			<5005D45D.1040302@genband.com>
		 <20120717.141153.46613285253481776.davem@davemloft.net>
		 <500978C7.5050004@genband.com> <50097FBD.9080202@redhat.com>
	 <1342806146.2678.31.camel@bwh-desktop.uk.solarflarecom.com>
	 <5009B186.6000806@genband.com>
 <1342814473.2678.65.camel@bwh-desktop.uk.solarflarecom.com>
 <5009ECDF.4090305@genband.com> <500D59BF.9040006@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Ben Hutchings <bhutchings@solarflare.com>,
	David Miller <davem@davemloft.net>,
	"yuvalmin@broadcom.com" <yuvalmin@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: Don Dutile <ddutile@redhat.com>,
	Chris Friesen <chris.friesen@genband.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <500D59BF.9040006@redhat.com>
Content-Language: en-US
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Don Dutile [mailto:ddutile@redhat.com]
> Sent: Monday, July 23, 2012 7:04 AM
> To: Chris Friesen
> Cc: Ben Hutchings; David Miller; yuvalmin@broadcom.com; Rose, Gregory V;
> netdev@vger.kernel.org; linux-pci@vger.kernel.org
> Subject: Re: New commands to configure IOV features
> 
> On 07/20/2012 07:42 PM, Chris Friesen wrote:
> > On 07/20/2012 02:01 PM, Ben Hutchings wrote:
> >> On Fri, 2012-07-20 at 13:29 -0600, Chris Friesen wrote:
> >
> >>> Once the device exists, then domain-specific APIs would be used to
> >>> configure it the same way that they would configure a physical device.
> >>
> >> To an extent, but not entirely.
> >>
> >> Currently, the assigned MAC address and (optional) VLAN tag for each
> >> networking VF are configured via the PF net device (though this is
> >> done though the rtnetlink API rather than ethtool).
> >
> > I actually have a use-case where the guest needs to be able to modify
> the MAC addresses of network devices that are actually VFs.
> >
> > The guest is bonding the network devices together, so the bonding driver
> in the guest expects to be able to set all the slaves to the same MAC
> address.
> >
> > As I read the ixgbe driver, this should be possible as long as the host
> hasn't explicitly set the MAC address of the VF. Is that correct?
> >
> > Chris
> 
> Interesting tug of war: hypervisors will want to set the macaddrs for
> security reasons,
>                          some guests may want to set macaddr for (valid?)
> config reasons.

It is a matter of trust.  The ability to set your own MAC address filters is a potential security issue, so host administrators have the ability to determine whether they trust the VF (and implicitly, the domain in which the VF resides).  There is also a sort of half-way solution.  By turning off anti-spoofing you can allow the VF to use source MAC addresses that are not actually assigned in HW filters.  This was done to support some bonding scenarios where the VF will need to transmit with a different source address.

Many applications using SR-IOV are embedded devices such as switches, edge relay devices, IP forwarding/filtering appliances, routers, etc.  More often than not the host administrator can trust domains that the VFs are assigned to because those domains are completely under the control of the local host.  In those cases the VFs are trusted and can be allowed to set their own MAC filters and use any source MAC address they please.

Other applications might need to assign VF devices to non-trusted domains.  Perhaps a service provider has leased a virtual machine domain to a subscriber who has purchased QoS levels that can only be met with the performance levels available with SR-IOV VF devices.  Other scenarios exist.  In these cases it is worthwhile to be able to restrict the VF's ability to set MAC filters and use source MAD addresses not assigned to it.

Rather than a tug of war I just view it as balancing security concerns with levels of additional capability and functionality.  That goes on all the time.

- Greg
