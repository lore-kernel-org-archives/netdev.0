From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: phy: b53: switchdev driver for Broadcom BCM53xx
 switches
Date: Thu, 26 Feb 2015 17:21:47 +0100
Message-ID: <20150226162147.GF8806@lunn.ch>
References: <54ED19AB.7020003@gmail.com>
 <CACna6rzMcVd7SJ6NTBrrWtXe1ZTgxF5tgVb08eaPxxwTxWU1cg@mail.gmail.com>
 <20150225140356.GB17992@lunn.ch>
 <CACna6ryQzXQn4Gxn701pXCU6MrZje+w-5B0htM+-PukMbq7ZFQ@mail.gmail.com>
 <20150225141945.GC17992@lunn.ch>
 <CACna6ryUgu3wmQGmU1EomY-CDpBfh2BN8_K+V-XD_3mj4txLDw@mail.gmail.com>
 <20150226151830.GD8806@lunn.ch>
 <CACna6rwVRB2q89EOKNK=5iQogE6_LBGUo1=M1ED0OaR7UqLAAg@mail.gmail.com>
 <20150226153605.GE8806@lunn.ch>
 <CACna6rxsu8Dmzm8wy9c50=qT7te8Du0Rg27N8BN8-M6h06uLMw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	"David S. Miller" <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	Felix Fietkau <nbd@openwrt.org>, Jiri Pirko <jiri@resnulli.us>
To: Rafa?? Mi??ecki <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:50364 "EHLO vps0.lunn.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751597AbbBZQYx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 11:24:53 -0500
Content-Disposition: inline
In-Reply-To: <CACna6rxsu8Dmzm8wy9c50=qT7te8Du0Rg27N8BN8-M6h06uLMw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 26, 2015 at 04:49:51PM +0100, Rafa?? Mi??ecki wrote:
> On 26 February 2015 at 16:36, Andrew Lunn <andrew@lunn.ch> wrote:
> >> It doesn't really answer my question as I don't see functionality I'm
> >> looking for in bcm_sf2. I don't see it handling (un)tagging or PVID
> >> anywhere. It makes me believe such features are not implemented (and
> >> not configurable) using bridges/dsa at all. Can you any API related to
> >> untagging / PVID?
> >
> > The (un)tagging code is in net/dsa/tag_brcm.c This is generic code, so
> > you would not expect to find it in bcm_sf2. All you need to do is set
> >
> >         .tag_protocol           = DSA_TAG_PROTO_BRCM,
> >
> > in your dsa_switch_driver structure and the core DSA code will ensure
> > the packets gets the header applied/removed.
> 
> Sorry, I wasn't clear enough. I don't mean Broadcom proto tagging, but
> a 802.1Q VLAN header including e.g. VID.
> 
> I'd like to have control over VLAN ID ports are using. The hardware
> allows me to define VLAN with a number and also if:
> 1) Packets incoming on port X should be modified (by hw) to include
> 802.11Q header
> 2) Packets leaving port Y should be stripped out of 802.11Q header or not
> 
> Above allows me to create some fun setups. For example I can configure
> my Linux interface to send packets with VID N. Then I can tell
> hardware to:
> 1) Send packets with VID N untagged to port 1
> 2) Send packets with VID N still tagged to port 2

Ah, O.K.

DSA does not allow that, at the moment. The Marvell switches do
however support this. So i expect at some point it will get added.
This is actually a layer or two up. First you need plain packets
without 802.11q supported. Then you can add 802.11q on top of that,
using standard linux concepts. Then we can add ingress/egress VLAN tag
stripping/adding. This last part is maybe a new concept with linux,
since it is something we want in general, and not just when using the
SW bridge.

So lets say you have DSA slave interfaces lan1 and lan2

You could then do

vconfig add lan1 42 --strip
vconfig add lan2 42 

You could then add these lan1:42 and lan2:42 interfaces to the bridge
to get what you want?

    Andrew
