From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx switches
Date: Thu, 26 Feb 2015 16:49:51 +0100
Message-ID: <CACna6rxsu8Dmzm8wy9c50=qT7te8Du0Rg27N8BN8-M6h06uLMw@mail.gmail.com>
References: <54ED017E.6000902@gmail.com>
	<20150225001534.GB15633@lunn.ch>
	<54ED19AB.7020003@gmail.com>
	<CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
	<20150225140356.GB17992@lunn.ch>
	<CACna6ryQzXQn4Gxn701pXCU6MrZje+w-5B0htM+-PukMbq7ZFQ@mail.gmail.com>
	<20150225141945.GC17992@lunn.ch>
	<CACna6ryUgu3wmQGmU1EomY-CDpBfh2BN8_K+V-XD_3mj4txLDw@mail.gmail.com>
	<20150226151830.GD8806@lunn.ch>
	<CACna6rwVRB2q89EOKNK=5iQogE6_LBGUo1=M1ED0OaR7UqLAAg@mail.gmail.com>
	<20150226153605.GE8806@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f181.google.com ([209.85.223.181]:43894 "EHLO
	mail-ie0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbbBZPtw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 10:49:52 -0500
Received: by iebtr6 with SMTP id tr6so16819587ieb.10
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 07:49:51 -0800 (PST)
In-Reply-To: <20150226153605.GE8806@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26 February 2015 at 16:36, Andrew Lunn <andrew@lunn.ch> wrote:
>> It doesn't really answer my question as I don't see functionality I'=
m
>> looking for in bcm_sf2. I don't see it handling (un)tagging or PVID
>> anywhere. It makes me believe such features are not implemented (and
>> not configurable) using bridges/dsa at all. Can you any API related =
to
>> untagging / PVID?
>
> The (un)tagging code is in net/dsa/tag_brcm.c This is generic code, s=
o
> you would not expect to find it in bcm_sf2. All you need to do is set
>
>         .tag_protocol           =3D DSA_TAG_PROTO_BRCM,
>
> in your dsa_switch_driver structure and the core DSA code will ensure
> the packets gets the header applied/removed.

Sorry, I wasn't clear enough. I don't mean Broadcom proto tagging, but
a 802.1Q VLAN header including e.g. VID.

I'd like to have control over VLAN ID ports are using. The hardware
allows me to define VLAN with a number and also if:
1) Packets incoming on port X should be modified (by hw) to include
802.11Q header
2) Packets leaving port Y should be stripped out of 802.11Q header or n=
ot

Above allows me to create some fun setups. For example I can configure
my Linux interface to send packets with VID N. Then I can tell
hardware to:
1) Send packets with VID N untagged to port 1
2) Send packets with VID N still tagged to port 2

I don't see any way to achieve that with dsa. On the other hand this
is what my proposed b53 driver allows. I could achieve above setup
using:
bridge vlan add vid N dev sw0p1 pvid untagged
bridge vlan add vid N dev sw0p2
bridge vlan add vid N dev sw0p8

--=20
Rafa=C5=82
