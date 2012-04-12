From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 1/2] net: ethtool: Add capability to retrieve
 plug-in module EEPROM
Date: Thu, 12 Apr 2012 19:41:58 +0100
Message-ID: <1334256118.2497.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <4F71FE0A.3060203@solarflare.com>
	  <1333389160.2623.30.camel@bwh-desktop.uk.solarflarecom.com>
	  <4F85B639.5090900@solarflare.com>
	  <1334168217.2552.5.camel@bwh-desktop.uk.solarflarecom.com>
	 <1334187728.2552.7.camel@bwh-desktop.uk.solarflarecom.com>
	 <4F869DF0.1000709@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <bruce.w.allan@intel.com>,
	<mirq-linux@rere.qmqm.pl>, <decot@google.com>,
	<amit.salecha@qlogic.com>, <alexander.h.duyck@intel.com>,
	<davem@davemloft.net>, <linux-kernel@vger.kernel.org>
To: Stuart Hodgson <smhodgson@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4F869DF0.1000709@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-04-12 at 10:18 +0100, Stuart Hodgson wrote:
> On 12/04/12 00:42, Ben Hutchings wrote:
[...]
> > Maybe we should start by refactoring ethtool_get_eeprom() so we can
> > reuse most of its code in ethtool_get_module_eeprom(), rather than
> > having to worry about what the maximum size of a module EEPROM might be
> > and whether we need a loop:
> >
> > Subject: ethtool: Split ethtool_get_eeprom() to allow for additional EEPROM accessors
[...]
> > @@ -771,7 +770,7 @@ static int ethtool_get_eeprom(struct net_device *dev, void __user *useraddr)
> >   		return -EINVAL;
> >
> >   	/* Check for exceeding total eeprom len */
> > -	if (eeprom.offset + eeprom.len>  ops->get_eeprom_len(dev))
> > +	if (eeprom.offset + eeprom.len>  total_len)
> >   		return -EINVAL;
> >
> >   	data = kmalloc(PAGE_SIZE, GFP_USER);
> 
> Should this not be eeprom.len?
[...]

No, because this function loops over PAGE_SIZE chunks.  That's
presumably necessary for large NIC EEPROMs, and if we reuse it we won't
have to wory about whether it's ever necessary for large module EEPROMs.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
