From: B Viswanath <marichika4@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Thu, 26 Feb 2015 12:44:02 +0530
Message-ID: <CAN+pFwLG7RE5pUbXmD8+=J=-e1j4E6=iP=g1ENSoZZ6w6HJkog@mail.gmail.com>
References: <20150224223039.GC1332@gospo.home.greyhouse.net>
	<CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
	<54ED017E.6000902@gmail.com>
	<20150225001534.GB15633@lunn.ch>
	<54ED19AB.7020003@gmail.com>
	<CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
	<20150225140356.GB17992@lunn.ch>
	<20150225154607.GD1332@gospo.home.greyhouse.net>
	<CAE4R7bB0ZqjA+2C7EL7fe0o1fvzoNofMmZsbD6FK4_ZYKXdrhg@mail.gmail.com>
	<20150226042158.GF1332@gospo.home.greyhouse.net>
	<20150226064755.GA2074@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Gospodarek <gospo@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	"Rafa?? Mi??ecki" <zajec5@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:34387 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbbBZHOD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 02:14:03 -0500
Received: by pdjg10 with SMTP id g10so11027975pdj.1
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 23:14:02 -0800 (PST)
In-Reply-To: <20150226064755.GA2074@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 February 2015 at 12:17, Jiri Pirko <jiri@resnulli.us> wrote:
> Thu, Feb 26, 2015 at 05:21:58AM CET, gospo@cumulusnetworks.com wrote:
>>On Wed, Feb 25, 2015 at 04:53:24PM -0800, Scott Feldman wrote:
>>> On Wed, Feb 25, 2015 at 7:46 AM, Andy Gospodarek
>>> <gospo@cumulusnetworks.com> wrote:
>>> > On Wed, Feb 25, 2015 at 03:03:56PM +0100, Andrew Lunn wrote:
>>> > [...]
>>> >>
>>> >> What we don't want is X chip families and Y different ways to
>>> >> configure the features. Ideal we want X chip families, and one way to
>>> >> configure them all.
>>> >
>>> > This statement is really my primary concern.  There is lots of interest
>>> > around hardware offload at this point and it seems like there is a risk
>>> > that a lack of consistency can create problems.
>>> >
>>> > I think these patches are great as they allow for the programming of the
>>> > offload hardware (and it has been pointed out that this drastically
>>> > increases performance), but one concern I have with this patch (related
>>> > to this) is that I'm not sure there is a major need to create netdevs
>>> > automatically if there is not the ability to rx/tx actual frames on
>>> > these interfaces.
>>>
>>> Even when not used for rx/tx to CPU, it seems the netdevs are still
>>> useful as an anchor to build higher-level constructs such as bridge or
>>> bond, and to hang stuff like netdev stats or ethtool-ish things.
>>>
>>
>>I agree that they are useful, but now we are really dealing with a
>>netdev that is slightly lower functionality than we expect from a netdev
>>right now.
>
> Is that a real care for some device now?
> I agree with Scott that we need to model is consistently. If there is
> such port netdev witch cannot tx/rx, we can expose the fact using some
> flag...

I would like to add that the 'requirements' are changing significantly
in this market. Until a while ago, all of the switch-ports were
considered a single device (and generally called LAN). If the
underlying driver exposed them as individual ports, then, they were
put-into a bridge, and used as such. The real reason for this was that
nobody was interested in individual packets from individual ports. If
packet comes to CPU because it could not be switched inside the
silicon, it was routed by the CPU (LAN to WAN). For those devices that
have wlan, the wlan interface was also added to the 'bridge'. This
bridge device really represented the 'LAN' of the network.

Now, there are requirements propping up which need more intelligence
in the 'router product'. This router is becoming center to a connected
home, with set-top boxes and IPTV behind, and even with a user
configurable DMZ port. Protocols are being run on LAN (like spanning
tree, and GxRP). All this mean, the software on the router needs to
look inside the LAN bridge and can't be content with a top-level
interface.

I guess I am saying that keeping netdevs for individual ports is going
to be a need, if it is not already there today. We will also see
traffic flowing on these netdevs in addition to statistics and other
stuff.  Keeping netdevs also makes it, as others say, consistent with
the management model.

>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
