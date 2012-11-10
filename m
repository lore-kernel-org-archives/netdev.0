From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] 8021q: validate SAN MAC address
Date: Fri, 9 Nov 2012 16:44:47 -0800
Message-ID: <1352508287.6276.7.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
References: <1352501644-8444-1-git-send-email-mchan@broadcom.com>
 <1352502165.3159.21.camel@bwh-desktop.uk.solarflarecom.com>
 <1352507122.6276.2.camel@LTIRV-MCHAN1.corp.ad.broadcom.com>
 <1352507762.3159.26.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=cp1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Ben Hutchings" <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2165 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694Ab2KJAo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Nov 2012 19:44:57 -0500
In-Reply-To: <1352507762.3159.26.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-11-10 at 00:36 +0000, Ben Hutchings wrote: 
> On Fri, 2012-11-09 at 16:25 -0800, Michael Chan wrote:
> > On Fri, 2012-11-09 at 23:02 +0000, Ben Hutchings wrote:
> > > > Some bnx2x multi-function devices are configured for FCoE only in
> > > > a PCI function and only has a SAN MAC address.  The current code
> > > > will fail ->ndo_validate_addr() when a VLAN device is brought up
> > > > over such a device.
> > > > 
> > > > Check the real device's dev_addrs[] for a valid SAN MAC address
> > > > when validating the MAC address if the regular MAC address is not
> > > > valid.
> > > 
> > > So the VLAN device's own address is being completely ignored?
> > 
> > No, it is not being ignored.  We validate the VLAN's regular MAC address
> > first.  If it is invalid, check further to see if the real device has a
> > SAN MAC address.
> 
> Sure, but in the case that the VLAN device is layered on one of these
> FCoE SAN devices, the VLAN device's address isn't validated.  Which
> presumably means it's not going to be used at all...
> 
> What does the VLAN device actually do in this case?  Is it a way of
> setting a VID to be used for the FCoE encapsulation?

Yeah, fcoemon first gets the SAN MAC from the physical device (using
DCBNL) and uses it send out packets for VLAN discovery.  After the VLAN
has been discovered, it will create the VLAN device over the physical
device and will try to bring it up.  After that, fcoemon will continue
to use the SAN MAC over the VLAN device.
