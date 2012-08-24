From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 13/13] igb: Store the MAC address in the name in the
 PTP struct.
Date: Fri, 24 Aug 2012 08:19:57 +0200
Message-ID: <20120824061956.GA2212@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-14-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823104554.GA2238@netboy.at.omicron.at>
 <1345757737.2579.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	Matthew Vick <matthew.vick@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Stuart Hodgson <smhodgson@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:50772 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755891Ab2HXGUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 02:20:10 -0400
Received: by weyx8 with SMTP id x8so829378wey.19
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 23:20:08 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1345757737.2579.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 10:35:37PM +0100, Ben Hutchings wrote:
> 
> The name field is described as 'A short name to identify the clock'.  It
> is not stated whether this is meant to be the name of the clock *device*
> or the clock *driver*.  If it's the name of the device then some unique
> ID such as the permanent MAC address is required.

In an ideal world, there is only one clock device per system, so the
original concept was to use the driver name. The hardware designers
have ignored or not understood the "one clock per system" model, and
so, unfortunately, we have to deal with it.

A clock device can and should be connected to more than one network
device (see gianfar, dp83640), and to give it a MAC address is
misleading.

The ethtool solution works perfectly to go from interface->clock,
which is all the information that a user space PTP stack needs.

I think for sysfs and the ioctl it is nicer to have the driver name,
since it is associated with the clock and its capabilities.

Thanks,
Richard
