From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: [PATCH] dm9601: handle corrupt mac address
Date: Tue, 6 Jan 2009 16:29:28 +0800
Message-ID: <20090106082928.GB19690@localhost>
References: <20090106061414.GA3677@localhost> <87hc4cvp05.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:11039 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750753AbZAFI3a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 03:29:30 -0500
Content-Disposition: inline
In-Reply-To: <87hc4cvp05.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Peter,

On Tue, Jan 06, 2009 at 09:04:58AM +0100, Peter Korsgaard wrote:
> >>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:
> 
>  Wu> Some cheap devices ship with dangling EEPROM pins!
>  Wu> They always return invalid address ff:ff:ff:ff:ff:ff.
> 
>  Wu> Inherit the auto-generated address in this case,
>  Wu> so that these products can work with zero configuration.
> 
>  Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> 
>  Wu> +	/*
>  Wu> +	 * Overwrite the auto-generated address only with good ones.
>  Wu> +	 */
>  Wu> +	if (is_valid_ether_addr(mac))
>  Wu> +		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
>  Wu> +
> 
> Do we automatically get a random address in netdev nowadays without
> calling random_ether_addr? I didn't know that.

I confirmed based on both code review and tests.
The logic goes like this in usbnet.c:

  80 // randomly generated ethernet address
  81 static u8       node_id [ETH_ALEN];
...
1118 int
1119 usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
1120 {
...
1168         dev->net = net;
1169         strcpy (net->name, "usb%d");
1170         memcpy (net->dev_addr, node_id, sizeof node_id);
...
1192         // allow device-specific bind/init procedures
1193         // NOTE net->name still not usable ...
1194         if (info->bind) {
1195                 status = info->bind (dev, udev);


> Anyway, I would prefer to add a dev_warn mentioning the fact that
> we're using a random address (and which one).

I'll do that in another patch. Since I'd like to add one more similar
warning to dm9601_set_mac_address(). That warning helped me identify
this bug.

> Other than that,
> 
> Signed-off-by: Peter Korsgaard <jacmet@sunsite.dk>

Thanks,
Fengguang
