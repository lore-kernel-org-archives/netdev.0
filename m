From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Tue, 24 Feb 2015 23:56:28 +0100
Message-ID: <CACna6rxgwdm0YJqf0fTZFROUjC--aiKUNT=tLOF4XwyMrzjtnA@mail.gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
	<54ECFFC3.5070309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:34974 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379AbbBXW43 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2015 17:56:29 -0500
Received: by iecrl12 with SMTP id rl12so249393iec.2
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 14:56:28 -0800 (PST)
In-Reply-To: <54ECFFC3.5070309@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24 February 2015 at 23:48, Florian Fainelli <f.fainelli@gmail.com> w=
rote:
> On 24/02/15 09:42, Rafa=C5=82 Mi=C5=82ecki wrote:
>> BCM53xx is series of Broadcom Ethernet switches that can be found in
>> various (mostly home) routers.
>> They are quite simple switches with mainly just support for:
>> 1) Tagging incoming packets (PVID)
>> 2) Untagging outgoing packets
>> 3) Forwarding all packets across a single VLAN
>>
>> This driver is split into common code (module) and bus specific code=
=2E
>> Right now only PHY (MDIO) support is included, other could follow af=
ter
>> accepting this driver. It was successfully tested on BCM4706 SoC wit=
h
>> BCM53125.
>>
>> You could notice it's yet another try of submitting b53 driver. This
>> time it was modified to use recently introduced switchdev API which
>> hopefully make it possible to accept it mainline.
>
> This is good as a very basic driver,

Thanks :) That was exactly my point: to get a minimal driver (but
implementing the basic functionality!) accepted and then continue
improving it.


> there is still a bunch of things
> missing that might not be too hard to add to this submission:
>
> - fetching MIB counters through ethtool
> - reporting link state/parameters
> - changing MTU/Jumbo frame support
> - HW bridging support

I agree about missing features. I was already thinking about MIB, it
should be easy to support it with ethtool_ops and get_sset_count +
get_strings. Probably the same for link status. Not sure about HW
bridging.

Would you agree to work on having this basic driver accepted first
(like discussing code location, API usage) and then work on additional
features in separated patches? I think it would simplify the process
and could result in better core review, as people could focus on small
bunch of changes.

--=20
Rafa=C5=82
