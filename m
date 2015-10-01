From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [patch net-next v3 02/10] switchdev: introduce transaction item
 queue for attr_set and obj_add
Date: Thu, 1 Oct 2015 17:28:21 +0200
Message-ID: <20151001152821.GK20219@lunn.ch>
References: <1443081769-11193-3-git-send-email-jiri@resnulli.us>
 <20150925043640.GB18915@ketchup.lan>
 <CAE4R7bA=xwfNT1cEp7_B7zfiuqg=PZ421j+GNCP+hi9DrhccAA@mail.gmail.com>
 <20150924.225508.2124748200966556070.davem@davemloft.net>
 <20150925150303.GA21567@ketchup.mtl.sfl>
 <20150930185652.GA2455@ketchup.lan>
 <CAE4R7bBooYJTBTUpb6zCRfoZs4N9VW1exfFBZgY5B1FmdQVtpg@mail.gmail.com>
 <20151001151535.GA31603@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>, Jiri Pirko <jiri@resnulli.us>,
	Netdev <netdev@vger.kernel.org>,
	Ido Schimmel <idosch@mellanox.com>, eladr@mellanox.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	Guenter Roeck <linux@roeck-us.net>,
	"Rosen, Rami" <rami.rosen@intel.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Premkumar Jonnala <pjonnala@broadcom.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Jiri Pirko <jiri@mellanox.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:48424 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756724AbbJAP21 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 1 Oct 2015 11:28:27 -0400
Content-Disposition: inline
In-Reply-To: <20151001151535.GA31603@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > Does this help?  Maybe we should walk before running and focus on
> > getting non-batch ops working and then revisit?
> 
> I agree. I understand the need for a prepare phase, but it looks like it
> exists for specific combinations, i.e. stacked and bonded devices.
> 
> For basic Ethernet switch chips (even DSA), it is *for the moment* a bit
> too unnecessarily complex.

I think we are going to need it though. I have bonding on my TODO
list. That will put DSA into a stacked system.
 
> What I will suggest next, is to explicitly skip the prepare phase in DSA
> (with a good comment as you already suggested), and fix switchdev to
> allow drivers to return -EOPNOTSUPP from its commit phase.

The switches have a limited number of bonds, called trunks in Marvells
terminology. So we will need the prepare phase to say: Sorry, im out
of trunks, do it in software. And different chips have different
numbers of trunks, so it will need to go down into the chip driver,
the DSA layer probably cannot decide.

    Andrew
