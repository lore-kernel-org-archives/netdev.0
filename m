From: Greg KH <greg@kroah.com>
Subject: Re: How to replace control code in gdm72xx?
Date: Wed, 16 Jul 2014 13:40:04 -0700
Message-ID: <20140716204004.GA31349@kroah.com>
References: <53C6DF7C.8030109@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: devel@driverdev.osuosl.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, inaky@linux.intel.com
To: Michalis Pappas <mpappas@fastmail.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:43288 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751949AbaGPUkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 16:40:41 -0400
Content-Disposition: inline
In-Reply-To: <53C6DF7C.8030109@fastmail.fm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2014 at 09:24:28PM +0100, Michalis Pappas wrote:
> Hi,
> 
> I'm currently working on bringing the gdm72xx WiMAX driver out of
> staging. The driver currently uses two control channels:
> 
> 1. The SIOCDEVPRIVATE ioctl to send and receive state messages
> 
> 2. A customly defined netlink protocol for passing messages verbatim to
> the device controller
> 
> AFAIK both of the above are deprecated, so I considered switching to
> the interface defined in wimax.h, which defines a communication protocol
> over generic netlink that replaces (2) nicely. However it is not
> compatible with (1), as:
> 
> * Except from the device status, the gdm72xx driver uses two more types
> of messages (connection and OMA status), which is not supported
> by wimax.h.
> 
> * The gdm driver needs to be able to receive status messages from
> userspace, which is not supported by wimax.h either.

What type of status messages are needed to be sent to the driver?

> I therefore consider using the wimax stack as defined in wimax.h for the
> netlink part, but replacing the ioctl with a file under /sys/class/net/wm0/

Is anyone still working on wimax to even object to add new functions
like this?  :)

thanks,

greg k-h
