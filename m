From: Alan Stern <stern@rowland.harvard.edu>
Subject: Re: hso: remove usb_driver_claim_interface()
Date: Wed, 10 Sep 2008 09:55:31 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.0809100949410.2408-100000@iolanthe.rowland.org>
References: <48C7A4F5.2070607@option.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>,
	<linux-usb@vger.kernel.org>, netdev <netdev@vger.kernel.org>,
	Greg Kroah-Hartman <gregkh@suse.de>
To: Denis Joseph Barrow <D.Barow@option.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from iolanthe.rowland.org ([192.131.102.54]:33422 "HELO
	iolanthe.rowland.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751781AbYIJNzd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Sep 2008 09:55:33 -0400
In-Reply-To: <48C7A4F5.2070607@option.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 10 Sep 2008, Denis Joseph Barrow wrote:

> Hi Paulius,
> I'm not in a position yet to know if this patch is good, yet at least.
> hso_probe gets called once for each serial ttyHSx device
> usually four per usb stick modem & once for the hsox network device
> per modem.
>  
> From the comment on usb_driver_claim_interface
>  * This is used by usb device drivers that need to claim more than one
>  * interface on a device when probing (audio and acm are current examples).
> 
> I'm not used to USB terminology
> From my understanding of the code
> we are claiming more than one interface on the usb modem multiple ttyHSx devices
> & one network device. However we get probed once for each interface

The idea behind usb_driver_claim_interface() is that it allows a driver
to bind to an arbitrary interface, generally because the driver needs
control of multiple interfaces in order to manage the device.  For
example, an audio device might include both a control interface and a
data interface -- the driver would claim the data interface when it is
probed for the control interface, since both are needed to run the
device.

But if the interfaces are independent and the driver is going to be 
probed for both of them anyway then there is no need to claim either 
one.  Just let the usual probing mechanism do its job.

And there is never any need to claim the interface for which the driver 
is being probed, since the driver is already getting bound to that 
interface.

Alan Stern

