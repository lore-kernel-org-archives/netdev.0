From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH 10/14] net: dsa/mv88e6352: Implement EEPROM access
 functions
Date: Thu, 23 Oct 2014 09:40:52 -0700
Message-ID: <20141023164052.GB21343@roeck-us.net>
References: <1414037002-25528-1-git-send-email-linux@roeck-us.net>
 <1414037002-25528-11-git-send-email-linux@roeck-us.net>
 <20141023135412.GC25190@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	linux-kernel@vger.kernel.org, Chris Healy <chealy@imsco-us.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:58590 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751885AbaJWQlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2014 12:41:02 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1XhLRe-003vZd-1f
	for netdev@vger.kernel.org; Thu, 23 Oct 2014 16:41:02 +0000
Content-Disposition: inline
In-Reply-To: <20141023135412.GC25190@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 23, 2014 at 03:54:12PM +0200, Andrew Lunn wrote:
> On Wed, Oct 22, 2014 at 09:03:18PM -0700, Guenter Roeck wrote:
> > MV88E6352 supports read and write access to its configuration eeprom.
> 
> Hi Guenter
> 
> I don't have the datasheet for the MV88E6352. Is the EEPROM built in,
> or external on an i2c bus?
> 
External.

> > +static int mv88e6352_get_eeprom_len(struct dsa_switch *ds)
> > +{
> > +	return 0x200;
> > +}
> 
> How do you handle the case of it being external and not populated.
> Would it not be better to try to detect it here, and return 0 if it
> does not exist?
> 
Makes sense, if it is detectable that it the EEPROM not there. Browsing
through the datasheet, I don't see how I could detect it; there does not
seem to be a status bit indicating if the EEPROM is there or not. There
are sw_mode pins which determine if the eeprom should be loaded after
reset or not, but I don't see anything in the register set which would
tell me.

Chris, do you know if there is a means to detect if the EEPROM is present
on the MV88E6352 ?

Thanks,
Guenter
