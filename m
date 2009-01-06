From: Wu Fengguang <wfg@linux.intel.com>
Subject: Re: [PATCH] dm9601: warn on invalid mac address
Date: Tue, 6 Jan 2009 17:47:57 +0800
Message-ID: <20090106094757.GA19587@localhost>
References: <20090106091050.GA19316@localhost> <87zli4u71i.fsf@macbook.be.48ers.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Peter Korsgaard <jacmet@sunsite.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:15584 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751559AbZAFJsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 04:48:00 -0500
Content-Disposition: inline
In-Reply-To: <87zli4u71i.fsf@macbook.be.48ers.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 10:18:17AM +0100, Peter Korsgaard wrote:
> >>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:
> 
> Hi,
> 
>  Wu> Add warnings on invalid mac address to help disclose/debug problems.
>  Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>  Wu> ---
>  Wu>  drivers/net/usb/dm9601.c |   12 +++++++++++-
>  Wu>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
>  Wu> --- linux-2.6.orig/drivers/net/usb/dm9601.c
>  Wu> +++ linux-2.6/drivers/net/usb/dm9601.c
>  Wu> @@ -401,8 +401,12 @@ static int dm9601_set_mac_address(struct
>  Wu>  	struct sockaddr *addr = p;
>  Wu>  	struct usbnet *dev = netdev_priv(net);
>  
>  Wu> -	if (!is_valid_ether_addr(addr->sa_data))
>  Wu> +	if (!is_valid_ether_addr(addr->sa_data)) {
>  Wu> +		DECLARE_MAC_BUF(mac_buf);
>  Wu> +		print_mac(mac_buf, addr->sa_data);
>  Wu> +		dev_warn(&net->dev, "not setting invalid mac address %s\n", mac_buf);
> 
> This should be an error and not a warning.
> Notice that print_mac returns the string, so you can do:
> 
> dev_err(&net->dev, "... %s", print_mac(mac_buf, addr->sa_data));

OK.

>  Wu>  	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
>  Wu>  	dm_write_async(dev, DM_PHY_ADDR, net->addr_len, net->dev_addr);
>  Wu> @@ -449,6 +453,12 @@ static int dm9601_bind(struct usbnet *de
>  Wu>  	 */
>  Wu>  	if (is_valid_ether_addr(mac))
>  Wu>  		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
>  Wu> +	else {
>  Wu> +		DECLARE_MAC_BUF(mac_buf);
>  Wu> +		print_mac(mac_buf, mac);
>  Wu> +		devdbg(dev, "EEPROM reported mac address %s is invalid,"
>  Wu> +				" use the randomly generated one.", mac_buf);
> 
> And this should be a warning.

Then let the warning message appear repeatedly for some devices?

Also dev_warn() won't be able to show the device name at that time,
like this:

[28489.062180]  : EEPROM reported mac address ff:ff:ff:ff:ff:ff is invalid, use the randomly generated one.

Thanks,
Fengguang

