From: Ben Hutchings <bhutchings@solarflare.com>
Subject: RE: [net-next 4/6] igb: Store the MAC address in the name in the
 PTP struct.
Date: Fri, 7 Sep 2012 00:39:30 +0100
Message-ID: <1346974770.2714.64.camel@bwh-desktop.uk.solarflarecom.com>
References: <1346888106-25638-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1346888106-25638-5-git-send-email-jeffrey.t.kirsher@intel.com>
	 <20120906080628.GD2550@netboy.at.omicron.at>
	 <02874ECE860811409154E81DA85FBB580785F9F4@ORSMSX105.amr.corp.intel.com>
	 <1346973787.2714.62.camel@bwh-desktop.uk.solarflarecom.com>
	 <02874ECE860811409154E81DA85FBB580785FA77@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Vick, Matthew" <matthew.vick@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35518 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751570Ab2IFXje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Sep 2012 19:39:34 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB580785FA77@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-06 at 23:24 +0000, Keller, Jacob E wrote:
> > -----Original Message-----
> > From: Ben Hutchings [mailto:bhutchings@solarflare.com]
> > Sent: Thursday, September 06, 2012 4:23 PM
> > To: Keller, Jacob E; Richard Cochran
> > Cc: Kirsher, Jeffrey T; davem@davemloft.net; Vick, Matthew;
> > netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
> > Subject: RE: [net-next 4/6] igb: Store the MAC address in the name in the
> > PTP struct.
> > 
> > On Thu, 2012-09-06 at 22:59 +0000, Keller, Jacob E wrote:
> > > > -----Original Message-----
> > > > From: netdev-owner@vger.kernel.org
> > > > [mailto:netdev-owner@vger.kernel.org]
> > > > On Behalf Of Richard Cochran
> > > > Sent: Thursday, September 06, 2012 1:06 AM
> > > > To: Kirsher, Jeffrey T
> > > > Cc: davem@davemloft.net; Vick, Matthew; netdev@vger.kernel.org;
> > > > gospo@redhat.com; sassmann@redhat.com
> > > > Subject: Re: [net-next 4/6] igb: Store the MAC address in the name
> > > > in the PTP struct.
> > > >
> > > > On Wed, Sep 05, 2012 at 04:35:04PM -0700, Jeff Kirsher wrote:
> > > > > From: Matthew Vick <matthew.vick@intel.com>
> > > > >
> > > > > Change the name of the adapter in the PTP struct to enable easier
> > > > > correlation between interface and PTP device.
> > > >
> > > > Still think it is better to have the driver name, not the MAC address.
> > > > The correlation is clear by using the ethtool method.
> > > >
> > >
> > > I found a method to correct the init code so that the device name can
> > > appear here, and I would prefer that over either the driver name or
> > > MAC address. It requires moving the ptp initialization into the netdev
> > > open handler though.
> > 
> > I don't think you should use the net device name for this, as net devices
> > can be renamed after creation.  (Though you could update the struct
> > ptp_clock_info whenever this happens.)
> > 
> > I'm starting to wonder what use there is for a 'clock name' distinct from
> > the clock device name.  What would be more useful is to give it a parent.
> > Richard, is there any reason why ptp_clock_register() doesn't allow
> > specifying the parent device?  You can then make the clock_name attribute
> > contain the parent device's driver name or whatever it is you prefer.
> > 
> > Ben.
> 
> Because ideally the ptp device belongs to multiple ethernet devices...
> 
> Sadly current intel hardware doesn't support this.

The PTP clock is instantiated by some driver, bound to some device,
whether that's a PCI device or a platform device or something else.  I
think that device (not a net device) should be the parent of the clock
device.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
