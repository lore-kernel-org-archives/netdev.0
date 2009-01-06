From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dm9601: warn on invalid mac address
Date: Tue, 06 Jan 2009 10:52:26 -0800 (PST)
Message-ID: <20090106.105226.58880881.davem@davemloft.net>
References: <20090106091050.GA19316@localhost>
	<87zli4u71i.fsf@macbook.be.48ers.dk>
	<1231242755.3789.9.camel@deadeye.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jacmet@sunsite.dk, wfg@linux.intel.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43197
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750988AbZAFSwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 13:52:24 -0500
In-Reply-To: <1231242755.3789.9.camel@deadeye.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Tue, 06 Jan 2009 11:52:35 +0000

> On Tue, 2009-01-06 at 10:18 +0100, Peter Korsgaard wrote:
> > >>>>> "Wu" == Wu Fengguang <wfg@linux.intel.com> writes:
> > 
> > Hi,
> > 
> >  Wu> Add warnings on invalid mac address to help disclose/debug problems.
> >  Wu> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> >  Wu> ---
> >  Wu>  drivers/net/usb/dm9601.c |   12 +++++++++++-
> >  Wu>  1 file changed, 11 insertions(+), 1 deletion(-)
> > 
> >  Wu> --- linux-2.6.orig/drivers/net/usb/dm9601.c
> >  Wu> +++ linux-2.6/drivers/net/usb/dm9601.c
> >  Wu> @@ -401,8 +401,12 @@ static int dm9601_set_mac_address(struct
> >  Wu>  	struct sockaddr *addr = p;
> >  Wu>  	struct usbnet *dev = netdev_priv(net);
> >  
> >  Wu> -	if (!is_valid_ether_addr(addr->sa_data))
> >  Wu> +	if (!is_valid_ether_addr(addr->sa_data)) {
> >  Wu> +		DECLARE_MAC_BUF(mac_buf);
> >  Wu> +		print_mac(mac_buf, addr->sa_data);
> >  Wu> +		dev_warn(&net->dev, "not setting invalid mac address %s\n", mac_buf);
> > 
> > This should be an error and not a warning.
> > Notice that print_mac returns the string, so you can do:
> > 
> > dev_err(&net->dev, "... %s", print_mac(mac_buf, addr->sa_data));
> 
> print_mac() is already obsolete; use %pM in the format string instead.

Yep, please fix this.
