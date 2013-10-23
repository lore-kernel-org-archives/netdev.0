From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Wed, 23 Oct 2013 07:34:08 -0400
Message-ID: <20131023113408.GA21456@hmsreliant.think-freely.org>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com>
 <1382466229-15123-2-git-send-email-f.fainelli@gmail.com>
 <5266D7D6.9000309@intel.com>
 <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com>
 <20131022202537.GA16336@hmsreliant.think-freely.org>
 <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Felix Fietkau <nbd@openwrt.org>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60664 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897Ab3JWLe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Oct 2013 07:34:27 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 22, 2013 at 03:09:32PM -0700, Florian Fainelli wrote:
> 2013/10/22 Neil Horman <nhorman@tuxdriver.com>:
> > On Tue, Oct 22, 2013 at 12:59:12PM -0700, Florian Fainelli wrote:
> >> 2013/10/22 John Fastabend <john.r.fastabend@intel.com>:
> >> > On 10/22/2013 11:23 AM, Florian Fainelli wrote:
> >> >>
> >> >> This patch adds an Ethernet Switch generic netlink configuration API
> >> >> which allows for doing the required configuration of managed Ethernet
> >> >> switches commonly found in Wireless/Cable/DSL routers in the market.
> >> >>
> >> >> Since this API is based on the Generic Netlink infrastructure it is very
> >> >> easy to extend a particular switch driver to support additional features
> >> >> and to adapt it to specific switches.
> >> >>
> >> >
> >> >> So far the API includes support for:
> >> >>
> >> >> - getting/setting a port VLAN id
> >> >> - getting/setting VLAN port membership
> >> >> - getting a port link status
> >> >> - getting a port statistics counters
> >> >> - resetting a switch device
> >> >> - applying a configuration to a switch device
> >> >>
> >> >
> >> > Did you consider exposing each physical switch port as a netdevice on
> >> > the host? I would assume your switch driver could do this.
> >> >
> >> > Then you can drop the port specific attributes (link status, stats, etc)
> >> > and use existing interfaces. The win being my tools work equally well on
> >> > your real switch as they do on my software switch. Also by exposing net
> >> > devices you provide a mechanism to send packets over the port and trap
> >> > control packets.
> >>
> >> Well this is exactly what DSA does and which I do not like because it
> >> is completely overkill for most switches out there which are using
> >> 802.1q tags and do not prepend/append proprietary tags for internal
> >> traffic classification.
> >>
> >> >
> >> > Next instead of creating a switch specific netlink API could you use
> >> > the existing FDB API? Again what I would like is for my existing
> >> > applications to run on the switch without having to rewrite them. For
> >> > example it would be great to have 'bridge fdb show dev myswitch' report
> >> > the correct tables for both the Sw bridge, a real switch bridge, and
> >> > for the embedded SR-IOV bridge case.
> >>
> >> Ok, I know nothing about the FDB API, but will take a look and see if
> >> that sounds suitable for the embedded use cases.
> >>
> > Further to Johns comments, why are you creating a new netlink protocol for this?
> > It seems that 90% of what you want to accomplish above is handled by rtnetlink.
> > As long as you write your driver properly, most of that should "just work".
> 
> This is not a new netlink protocol, but a generic netlink family. Why
Thats hair splitting.  The point I'm making here is that you're creating a new
communication path from user space to the kernel to do something that we already
have a communication path to do.

> would I extend rtnetlink to cover the remaining 10% which are not
> going to be used on desktop and servers when a new generic netlink
> family is cheap and can be selectively disabled in the kernel?
90% of it is already done on servers and desktops using rtnetlink (thats my
point), and you can reasonably add the other 10% (I think), if you just expose
the switch ports as their own ethernet interfaces.  You say DSA is overkill, but
if you just add the other switch ports as their own ethernet interfaces, you
would get most of the above work for free, which seems to me like less overkill
than a new netlink family and userspace tools. 

Regards
Neil
