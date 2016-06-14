From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v6] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Tue, 14 Jun 2016 15:08:49 +0000
Message-ID: <70b92fde9b5b4e478b0d50986cc09b41@ausx13mpc124.AMER.DELL.COM>
References: <1465323757-7249-1-git-send-email-mario_limonciello@dell.com>
	<20160610.225156.638004322598763463.davem@davemloft.net>
	<20160611153921.GP2338@lunn.ch>
 <20160611.104226.1571085838142610714.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <hayeswang@realtek.com>, <linux-kernel@vger.kernel.org>,
	<netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>,
	<pali.rohar@gmail.com>, <anthony.wong@canonical.com>,
	<gregkh@linuxfoundation.org>
To: <davem@davemloft.net>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from AUSXIPPS310.us.dell.com ([143.166.148.211]:39543 "EHLO
	ausxipps310.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750985AbcFNPIw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jun 2016 11:08:52 -0400
In-Reply-To: <20160611.104226.1571085838142610714.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: Saturday, June 11, 2016 12:42 PM
> To: andrew@lunn.ch
> Cc: Limonciello, Mario <Mario_Limonciello@Dell.com>;
> hayeswang@realtek.com; linux-kernel@vger.kernel.org;
> netdev@vger.kernel.org; linux-usb@vger.kernel.org; pali.rohar@gmail.com;
> anthony.wong@canonical.com; gregkh@linuxfoundation.org
> Subject: Re: [PATCH v6] r8152: Add support for setting pass through MAC
> address on RTL8153-AD
> 
> From: Andrew Lunn <andrew@lunn.ch>
> Date: Sat, 11 Jun 2016 17:39:21 +0200
> 
> > What is still open is do we want to accept it at all? Do we accept the
> > concept of putting the same MAC address on multiple interfaces at
> > hotplug time? Do we trust BIOS vendors to not keep changing DSDT
> > property name, since it is not standardised?
> >

It's worth saying - standardized a property name doesn't indemnify it.
Properties change all the time from one version of a spec to another.

I can only speak for Dell, but it's in our best interest to keep the BIOS
side of the codebase around this simpler too.

> > Do we want this at all should be decided by somebody more senior then
> > those passing comments on the code.
> 
> Indeed, I think the behavior of using the same MAC address on multiple
> interfaces if we plug several of these in at once is not good.
> 
> We shouldn't behave this way just because the Microsoft driver does.

This is really grasping at an extreme corner case scenario.

Dell TB15 and WD15 docks are currently only ones on the market with
RTL8135-AD and MAC address pass through efuse bit set.  These docks
are not inexpensive.  If someone really wants multiple USB NIC's plugged
in, they can pick up a second USB NIC from the web for far cheaper than
buying a second dock.

Also for what it's worth, the docks don't allow daisy chaining.  The dock EC's 
will reject the second dock from functioning through the downstream 
connection.  The only way that two docks could be hooked up and
functional is on a machine with multiple type C ports.

If you still think it's worth solving, what would you like done as an 
alternative?  I would really like to have some implementation of this
that you guys are comfortable with upstream.

There was already discussion and an implementation in this 
thread about tracking if the aux MAC was assigned to something and only 
allowing one device to get that assignment.  There was a limitation that 
you won't be able to know which device gets the auxiliary MAC address.  
It will be based solely upon hotplug order.

There was also in one version of the patch a way to turn off this behavior
In a module parameter.  Greg KH wasn't fond of that, so it's not present
in the current version.

I can add either of those back in if they would help the case.

Another option I wanted to offer was turning this behavior on via kernel
configuration option and let the distros decide if they want to turn it on
for users.
