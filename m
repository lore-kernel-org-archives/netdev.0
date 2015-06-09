From: Oliver Neukum <oneukum@suse.com>
Subject: Re: [RFC PATCH] cdc_ncm: support moving the NDP part of the frame
 to the end of NCM package
Date: Tue, 09 Jun 2015 12:38:59 +0200
Message-ID: <1433846339.28343.9.camel@suse.com>
References: <1433760296-18543-1-git-send-email-mrkiko.rs@gmail.com>
	 <1433760803.8770.16.camel@suse.com>
	 <alpine.LNX.2.20.1506090933410.2290@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Enrico Mioso <mrkiko.rs@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:45848 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750805AbbFIKjy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Jun 2015 06:39:54 -0400
In-Reply-To: <alpine.LNX.2.20.1506090933410.2290@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-06-09 at 09:46 +0200, Enrico Mioso wrote:

> ==Not another parameter please. If the alternate frames are processed as
> ==well as the current frames, all is well and we can generally produces
> ==such frames. If not, we want a black list.
> 
> I would agree on this point: and I was exploring different alternatives also, 
> such as having this option settable when invoking cdc_ncm_bind_common from
> huawei_cdc_ncm for example. Unfortunately, I don't feel confident we could do 
> that.

Using a module parameter is simply wrong. A system can be connected to
multiple devices (in turn). As a minimum the feature must be per device.

> First of all: this driver supports more devices than Huawei ones, so I feel we 
> have chances to break them modifying the frame structure.

In theory we must never break or impede compliant devices for
uncompliant devices. Yet I doubt we can break any device doing what
Windows does.
Does it have a standard NCM driver that works with Huawei devices?

> Even more complicated is the fact that huawei NCM devices are not easily 
> distinguishable one another from the driver perspective. Some heuristics may be 
> put in place probably, but I don't have access to old enough NCM devices to 
> know best.
> The Huawei vendor driver put NDPs at end of frame - and does so for all devices 
> in my opinion, but I can't be really sure about that.

Doesn't it have a list of supported devices?

> Not now. Anyway I can change this as desired. Would something like a sysfs knob 
> be preferable? User-space surely has a good chance to tell us what to do here.

Not really. The answer will come from a list. The question is just
whether easier updates are worth splitting up the fix.

> ==> --- a/include/linux/usb/cdc_ncm.h
> ==> +++ b/include/linux/usb/cdc_ncm.h
> ==> @@ -93,6 +93,7 @@ struct cdc_ncm_ctx {
> ==>  	const struct usb_cdc_mbim_desc *mbim_desc;
> ==>  	const struct usb_cdc_mbim_extended_desc *mbim_extended_desc;
> ==>  	const struct usb_cdc_ether_desc *ether_desc;
> ==> +	struct usb_cdc_ncm_ndp16 *delayed_ndp;
> ==
> ==What prevents you from embedding this in the structure?
> ==
> ==	Regards
> ==		Oliver
> ==
> ==
> ==
> Sorry - I think I didn't understand your ocmment here. Still, I am open to any 
> suggestion.

Why don't you put "struct usb_cdc_ncm_ndp16 delayed_ndp" as opposed to a
pointer to it into struct cdc_ncm_ctx. You never need more than one at a
time.

	Regards
		Oliver
