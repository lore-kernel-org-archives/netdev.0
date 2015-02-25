From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Wed, 25 Feb 2015 09:07:51 +0100
Message-ID: <20150225080751.GC2039@nanopsycho.orion>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
 <20150224223039.GC1332@gospo.home.greyhouse.net>
 <CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
 <54ED017E.6000902@gmail.com>
 <20150225001534.GB15633@lunn.ch>
 <54ED19AB.7020003@gmail.com>
 <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>
To: =?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:38269 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750771AbbBYIHz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 03:07:55 -0500
Received: by wesw55 with SMTP id w55so1926130wes.5
        for <netdev@vger.kernel.org>; Wed, 25 Feb 2015 00:07:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 25, 2015 at 08:03:48AM CET, zajec5@gmail.com wrote:
>On 25 February 2015 at 01:39, Florian Fainelli <f.fainelli@gmail.com> =
wrote:
>> On 24/02/15 16:15, Andrew Lunn wrote:
>>> On Tue, Feb 24, 2015 at 02:55:58PM -0800, Florian Fainelli wrote:
>>>> On 24/02/15 14:50, Rafa?? Mi??ecki wrote:
>>>>> As said in the commit message, these switches are really simple
>>>>> devices. We can't actually send packets to the particular ports
>>>>> (unless something has changed in the more recent hardware).
>>>>
>>>> These switches all support Broadcom tags, so you could use your ho=
st CPU
>>>> Ethernet MAC to send/receive packets to/from specific ports of the
>>>> switch, and then this is just like DSA, but everything that you sa=
y
>>>> below is true.
>>>
>>> If this hardware does support the concept of tags compatible to the
>>> existing Broadcom Starfighter 2, should we not do that? Is there a
>>> good reason these chips should use a difference abstraction than
>>> Starfighter 2 and the Marvell devices?
>>
>> No, I think that would be a reasonable thing to do, I am still a lit=
tle
>> unclear how the older BCM5325 and friends work with respect to broad=
com
>> tags, but regardless, DSA now understands switches that do not suppo=
rt
>> tags, so we should be good with some sort of b53 library.
>
>DSA doesn't allow me to use switch (hardware) VLANs. I would need to
>handle all forwarding in CPU. The most powerful Broadcom MIPS SoC -
>BCM4706 - can handle about 130 Mb/s. Less powerful - BCM4718A1 - only
>about 50 Mb/s.
>This is way too bad for performance when there is a 1 Gb/s switch and
>too bad for CPU usage.

Please correct me if I'm wrong Florian, but I believe that DSA does
allow setting up chips to do forwarding without packets going to CPU.

b53 looks like it fits nicely into DSA architecture. I believe that it
should be integrated there.

>
>I guess the whole idea of switchdev was to allow what proposed version
>of b53 does? To handle VLANs in hardware.
>
>--=20
>Rafa=C5=82
