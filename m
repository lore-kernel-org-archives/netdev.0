From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: add QCA alx Ethernet driver
Date: Thu, 01 Mar 2012 16:56:19 -0800
Message-ID: <1330649779.23314.80.camel@joe2Laptop>
References: <1330480210-30470-1-git-send-email-rodrigue@qca.qualcomm.com>
	 <20120228193237.2d56f2b8@nehalam.linuxnetplumber.net>
	 <20120301234007.GA18488@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"Luis R. Rodriguez" <rodrigue@qca.qualcomm.com>,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcgrof@frijolero.org,
	qca-linux-team@qualcomm.com, nic-devel@qualcomm.com,
	kgiori@qca.qualcomm.com, chris.snook@gmail.com,
	mathieu@qca.qualcomm.com, bryanh@quicinc.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:56030 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757767Ab2CBA4V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Mar 2012 19:56:21 -0500
In-Reply-To: <20120301234007.GA18488@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-03-02 at 00:40 +0100, Francois Romieu wrote:
> Stephen Hemminger <shemminger@vyatta.com> :
> [...]
> > Evolution is better. The new driver has lots of new callbacks to handle
> > the fact it is dealing with two different chipsets. Not only that your callbacks
> > are built at runtime which leads to security concerns.
> > 
> > There is a reason the two Marvell based drivers (skge and sky2) are
> > different drivers. Having to do extra per-chip callbacks is a clear sign
> > the driver should be split in two.
> 
> (arguable)
[]
> > +void alx_hw_printk(const char *level, const struct alx_hw *hw,
> > +		   const char *fmt, ...)
> > +{
> > +	struct va_format vaf;
> > +	va_list args;
> > +
> > +	va_start(args, fmt);
> > +	vaf.fmt = fmt;
> > +	vaf.va = &args;
> > +
> > +	if (hw && hw->adpt && hw->adpt->netdev)
> > +		__netdev_printk(level, hw->adpt->netdev, &vaf);
> > +	else
> > +		printk("%salx_hw: %pV", level, &vaf);
> > +
> > +	va_end(args);
> > +}
> 
> Designing a new logging facility smells like being unable to figure
> the current context.
> 
> And the printk does not even use KERN_... :o(

Sure it does.

level is the first argument and is emitted as %s

> > +/*
> > + *  alx_validate_mac_addr - Validate MAC address
> > + */
> > +static int alx_validate_mac_addr(u8 *mac_addr)
> > +{
> > +	int retval = 0;
> > +
> > +	if (mac_addr[0] & 0x01) {
> > +		printk(KERN_DEBUG "MAC address is multicast\n");
> > +		retval = -EADDRNOTAVAIL;
> > +	} else if (mac_addr[0] == 0xff && mac_addr[1] == 0xff) {
> > +		printk(KERN_DEBUG "MAC address is broadcast\n");
> > +		retval = -EADDRNOTAVAIL;
> > +	} else if (mac_addr[0] == 0 && mac_addr[1] == 0 &&
> > +		   mac_addr[2] == 0 && mac_addr[3] == 0 &&
> > +		   mac_addr[4] == 0 && mac_addr[5] == 0) {
> > +		printk(KERN_DEBUG "MAC address is all zeros\n");
> > +		retval = -EADDRNOTAVAIL;
> > +	}
> > +	return retval;
> > +}
> 
> Bloat. It should use is_valid_ether_addr.

I sent patches already.
It's also out of order, testing multicast then broadcast
instead of the reverse.
