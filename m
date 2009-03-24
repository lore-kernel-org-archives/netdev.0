From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: Network Device Naming mechanism and policy
Date: Tue, 24 Mar 2009 12:52:03 -0500
Message-ID: <20090324175203.GB22700@auslistsprd01.us.dell.com>
References: <20090324154617.GA16332@auslistsprd01.us.dell.com> <1237914139.22009.18.camel@quest>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Scott James Remnant <scott@ubuntu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:48897 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754223AbZCXRwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2009 13:52:07 -0400
Content-Disposition: inline
In-Reply-To: <1237914139.22009.18.camel@quest>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2009 at 05:02:19PM +0000, Scott James Remnant wrote:
> On Tue, 2009-03-24 at 10:46 -0500, Matt Domsch wrote:
> > biosdevname (http://linux.dell.com/projects.shtml#biosdevname) takes a
> > stab at this.  It can be integrated into udev, such that the
> > 70-persistent-net.rules file is never used, and the naming for each
> > device comes from several different policies.  Its primary drawback is
> > that it changes the device namespace, which some sysadmins, and tools,
> > may not like.  Names for devices become eth_s0_0 for the first
> > onboard NIC, eth_s0_1 for the second; eth_s3_3 for the fourth port
> > on PCI Slot #3, etc.
> > 
> While this works for PCI slots, it already doesn't scale to other buses.
> For example what slot number is the pccard slot?  If you have two
> different pccard devices, would they get assigned the same name (udev
> currently assigns them different names).

actually biosdevname handles this already, using eth_pccard_X.Y where
X = socket and Y = function.

> Now consider USB.  Would the device name change depending on which USB
> port you plugged it into?  Or is USB just a single slot, in which case
> what happens when you have two USB ethernet devices?
> 
> The Apple USB Ethernet device in my iPhone is not the USB Wireless
> adapter I own, both have very different networking configurations.

we would obviously need a solution.  eth_usb_{something} perhaps.

-- 
Matt Domsch
Linux Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
