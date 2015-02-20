From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH RFC 2/2] net: dsa: bcm_sf2: implement HW bridging
 operations
Date: Thu, 19 Feb 2015 19:55:14 -0800
Message-ID: <20150220035514.GA5017@roeck-us.net>
References: <1424201196-4901-1-git-send-email-f.fainelli@gmail.com>
 <1424201196-4901-3-git-send-email-f.fainelli@gmail.com>
 <54E54EF3.9020802@gmail.com>
 <20150219055953.GA14247@roeck-us.net>
 <54E61CFB.3010109@gmail.com>
 <20150219174640.GA6897@roeck-us.net>
 <54E676DD.9090003@gmail.com>
 <20150220000935.GA30118@roeck-us.net>
 <20150220020241.GF795@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, cphealy@gmail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:43236 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753017AbbBTDz1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Feb 2015 22:55:27 -0500
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YOegY-002hzM-FK
	for netdev@vger.kernel.org; Fri, 20 Feb 2015 03:55:26 +0000
Content-Disposition: inline
In-Reply-To: <20150220020241.GF795@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 20, 2015 at 03:02:41AM +0100, Andrew Lunn wrote:
> > Not sure yet what to do about setting the fdb aging time. I don't
> > see a mechanism to do that. No idea how important that is.
> 
> Hi Guenter
> 
> I don't know about your chip, but the public data sheet for the
> 88e6060 talks about being able to set the age time globally in the ATU
> control register. The granularity is not so good, multiple of 16
> seconds, so it could be the hardware bridge times out an entry faster
> than the software bridge.
> 
Yes, but only if the minimum is configured. The default is about 5.5
minutes on mv88e6352. I didn't check the default on the other 886exxx
chips, but I assume it is the same.

Problem is topology changes or non-standard aging times. Maybe fdb flush
on port status changes takes care of those cases; I am just not sure if
that is sufficient.

Guenter
