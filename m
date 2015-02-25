From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Wed, 25 Feb 2015 15:31:13 +0100
Message-ID: <20150225143113.GD17992@lunn.ch>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
 <54E76EFA.1050209@cumulusnetworks.com>
 <54E7876A.3060303@gmail.com>
 <FFEDCF9956066D4D97C463CC178C7F69F22E02@SJEXCHMB06.corp.ad.broadcom.com>
 <54E8CE77.3050709@cumulusnetworks.com>
 <CAE4R7bAPS1GZKaC4M6x9cqfTOkVju1+Po4KzanfSniEFX9oi1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa <roopa@cumulusnetworks.com>,
	Viswanath Bandaru <vbandaru@broadcom.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"linux@roeck-us.net" <linux@roeck-us.net>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>
To: Scott Feldman <sfeldma@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49134 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753288AbbBYOeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Feb 2015 09:34:17 -0500
Content-Disposition: inline
In-Reply-To: <CAE4R7bAPS1GZKaC4M6x9cqfTOkVju1+Po4KzanfSniEFX9oi1w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Geunter had this question in the thread:
> 
> "I may be missing something, but I don't immediately see how this patch set
> helps me solve any of the problems I am seeing when integrating the Marvell
> switch code. Even if the switch internally does hardware aging, it still
> seems to me that we'll need software aging on top of that, even if the
> bridge code in the kernel has the same addresses in its fdb as the switch.
> I see no feasible means to keep the fdb in the switch synchronized
> with the fdb in the kernel".
> 
> You'll want to turn learning off on the bridge, and enable learning (and
> learning_sync) in hardware.  The hw driver will install an FDB entry in the
> bridge's FDB and mark it "external".  The entry will also appear in the
> device's FDB.

I don't think this is going to work. There is no efficient way to get
the hardware tables out of the hardware. We don't get notification of
additions or removals. We can only read the whole table. And it can be
expensive to read the whole table, since it can be 1K or more entries,
going over an MDIO bus, which in the worst case can be bit banging on
gpio lines.

We probably need a design for devices where we can efficiently get
access to the hardware table, and use it in the software bridge. But
we also need a design where the SW and HW bridges have independently
tables.

	Andrew
