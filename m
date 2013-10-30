From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Wed, 30 Oct 2013 18:34:16 +0100
Message-ID: <20131030173416.GA32234@wantstofly.org>
References: <5267C6B9.4000704@mojatatu.com>
 <5267CFAB.9090100@openwrt.org>
 <5267D8AE.7080009@mojatatu.com>
 <5267DDE6.70600@openwrt.org>
 <526A5949.6040404@mojatatu.com>
 <526A6BB3.7050507@openwrt.org>
 <526D4B06.8040505@mojatatu.com>
 <526D6EBA.3020903@openwrt.org>
 <526EEAE9.6090508@mojatatu.com>
 <20131030172756.GM8570@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chris Healy <cphealy@gmail.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:61550 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751055Ab3J3ReS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 13:34:18 -0400
Content-Disposition: inline
In-Reply-To: <20131030172756.GM8570@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 30, 2013 at 06:27:56PM +0100, Lennert Buytenhek wrote:

> > >This means that all per-port netdevs will be dummy ports which don't
> > >include the data path.
> 
> And I think that's fine.
> 
> Look, even if you're not going to address data traffic to individual
> ports on your switch chip, there's still a plethora of per-port
> operations that you want to be able to do: administratively setting
> the link state on ports up and down, controlling autonegotiation and
> other PHY settings on individual ports, etc.
> 
> You can either let the administrator do this with the standard ifconfig
> / ip link / ethtool tools, or you can make up a parallel API and
> corresponding set of userland tools to duplicate most of the existing
> functionality -- I know which option I prefer.
> 
> Presenting each switch port as an individual Linux netdevice to the OS
> is an orthogonal decision to actually using those netdevices for data
> traffic, and conflating the two by arguing that you need special tools
> to do per-port operations for the sole reason that your switch chip
> cannot address individual ports is a rather confused argument.

Forgot to add: there's a patch for net/dsa that adds exactly such an
option.  We called it 'unmanaged' mode, and it doesn't enable packet
tagging on the CPU<->switch chip interface, so that data only ever
flows over a single network interface ("eth0"), while the other
("dummy") network interfaces ("port1", "port2", etc) are used for
setting link state with ip link, setting PHY settings with ethtool,
getting ethtool statistics, etc, with 100% unmodified userland tools.
This patch is currently buried inside a vendor tree, but I'd be happy
to dig it out and submit it.
