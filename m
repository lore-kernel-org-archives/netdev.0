From: B Viswanath <marichika4@gmail.com>
Subject: Re: [PATCH net-next RFC 0/5] Add NTF_EXT_AGED to control FDB ageing
 in SW or HW
Date: Wed, 25 Feb 2015 23:01:00 +0530
Message-ID: <CAN+pFwKft-f8wPuYbL7MB7O3UdqbKRACoEX44z4iM3BMkuu9eQ@mail.gmail.com>
References: <1424416195-19098-1-git-send-email-sfeldma@gmail.com>
	<54E76EFA.1050209@cumulusnetworks.com>
	<54E7876A.3060303@gmail.com>
	<FFEDCF9956066D4D97C463CC178C7F69F22E02@SJEXCHMB06.corp.ad.broadcom.com>
	<54E8CE77.3050709@cumulusnetworks.com>
	<CAE4R7bAPS1GZKaC4M6x9cqfTOkVju1+Po4KzanfSniEFX9oi1w@mail.gmail.com>
	<20150225143113.GD17992@lunn.ch>
	<20150225164303.GC25241@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andrew Lunn <andrew@lunn.ch>, Scott Feldman <sfeldma@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	Viswanath Bandaru <vbandaru@broadcom.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"jiri@resnulli.us" <jiri@resnulli.us>,
	"gospo@cumulusnetworks.com" <gospo@cumulusnetworks.com>,
	"siva.mannem.lnx@gmail.com" <siva.mannem.lnx@gmail.com>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f170.google.com ([209.85.192.170]:38705 "EHLO
	mail-pd0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752699AbbBYRbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:31:00 -0500
Received: by pdbfp1 with SMTP id fp1so6299592pdb.5
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 09:31:00 -0800 (PST)
In-Reply-To: <20150225164303.GC25241@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 February 2015 at 22:13, Guenter Roeck <linux@roeck-us.net> wrote:
>
<snip>

> > >
> > > You'll want to turn learning off on the bridge, and enable learning (and
> > > learning_sync) in hardware.  The hw driver will install an FDB entry in the
> > > bridge's FDB and mark it "external".  The entry will also appear in the
> > > device's FDB.
> >
> > I don't think this is going to work. There is no efficient way to get
> > the hardware tables out of the hardware. We don't get notification of
> > additions or removals. We can only read the whole table. And it can be
> > expensive to read the whole table, since it can be 1K or more entries,
> > going over an MDIO bus, which in the worst case can be bit banging on
> > gpio lines.
> >
> Which, coincidentially, is the case in my application. The newer
> Marvell switches support up to 8k forwarding table entries, so that
> would be really awkward.
>
> > We probably need a design for devices where we can efficiently get
> > access to the hardware table, and use it in the software bridge. But
> > we also need a design where the SW and HW bridges have independently
> > tables.
> >

I do agree that reading all of FDB into CPU is a pain. Given the table
size of 1K or 8K, I am (probably incorrectly) speculating that the
device may be a router primarily. Also, not having means of
learn-notifications and/or a quick (hw) interface to get all the
table, I (again probably incorrectly) speculate that there are not
many use cases associated with FDB and end-user/CPU for this silicon.

So I am thinking why would you want to read FDB to CPU ? You can
disable learning on the bridge and have the driver not send any
learning notifications to kernel, while the silicon continues to learn
and forward.  The end user may not be able see the FDB on a command,
but is this a requirement for you ?

I may be missing some use cases here, so would you mind mentioning ?

> Agreed.
>
> Some of the Marvell chip support accessing its registers through Ethernet,
> so that may be an option. That is not supported on all chips, so it would
> not be a generic solution, but it may be worthwhile looking into.
>
> Guenter
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
