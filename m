From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Wed, 25 Feb 2015 08:03:48 +0100
Message-ID: <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
References: <1424799727-30946-1-git-send-email-zajec5@gmail.com>
	<20150224223039.GC1332@gospo.home.greyhouse.net>
	<CACna6rwBUqebNpf9XC21+LxZtR7xLn6wM-KWuxHR=E0KT6MSdQ@mail.gmail.com>
	<54ED017E.6000902@gmail.com>
	<20150225001534.GB15633@lunn.ch>
	<54ED19AB.7020003@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Lunn <andrew@lunn.ch>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:62115 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516AbbBYHDt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 02:03:49 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so3583630iga.0
        for <netdev@vger.kernel.org>; Tue, 24 Feb 2015 23:03:48 -0800 (PST)
In-Reply-To: <54ED19AB.7020003@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25 February 2015 at 01:39, Florian Fainelli <f.fainelli@gmail.com> w=
rote:
> On 24/02/15 16:15, Andrew Lunn wrote:
>> On Tue, Feb 24, 2015 at 02:55:58PM -0800, Florian Fainelli wrote:
>>> On 24/02/15 14:50, Rafa?? Mi??ecki wrote:
>>>> As said in the commit message, these switches are really simple
>>>> devices. We can't actually send packets to the particular ports
>>>> (unless something has changed in the more recent hardware).
>>>
>>> These switches all support Broadcom tags, so you could use your hos=
t CPU
>>> Ethernet MAC to send/receive packets to/from specific ports of the
>>> switch, and then this is just like DSA, but everything that you say
>>> below is true.
>>
>> If this hardware does support the concept of tags compatible to the
>> existing Broadcom Starfighter 2, should we not do that? Is there a
>> good reason these chips should use a difference abstraction than
>> Starfighter 2 and the Marvell devices?
>
> No, I think that would be a reasonable thing to do, I am still a litt=
le
> unclear how the older BCM5325 and friends work with respect to broadc=
om
> tags, but regardless, DSA now understands switches that do not suppor=
t
> tags, so we should be good with some sort of b53 library.

DSA doesn't allow me to use switch (hardware) VLANs. I would need to
handle all forwarding in CPU. The most powerful Broadcom MIPS SoC -
BCM4706 - can handle about 130 Mb/s. Less powerful - BCM4718A1 - only
about 50 Mb/s.
This is way too bad for performance when there is a 1 Gb/s switch and
too bad for CPU usage.

I guess the whole idea of switchdev was to allow what proposed version
of b53 does? To handle VLANs in hardware.

--=20
Rafa=C5=82
