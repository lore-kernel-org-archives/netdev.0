From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 23 Oct 2013 14:04:35 +0200
Message-ID: <5267BB53.8030703@openwrt.org>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:52530 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753335Ab3JWMEy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 08:04:54 -0400
In-Reply-To: <5267B764.305@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-23 1:47 PM, Jamal Hadi Salim wrote:
> Florian,
> 
> I think it would be fantastic if you adopt the FDB API. The comment
> to use rtnetlink configure is valid. You can configure hardware
> switches as John has shown. I realize you guys have invested
> tons of time and this stuff has been tested by tons of people and this
> is a painful exercise to go through, but:
> having more than one approach for configuring/controlling kernel
> switch interfaces is not ideal. If you use the rtnetlink API then one
> can configure both the Linux bridge, embedded intel switches, etc with
> iproute2. i.e the switch becomes a bridge. I see a lot of commonolity
> between your model based on what you described and the current bridge.
> Pull the latest iproute2 code and look at "bridge" command.
> 
> Essentially, the current bridged could be described as an entity
> that does L2 switching:
> a) it has bridge ports which are any netdevs on Linux
> b) it has an FDB which constitutes a MAC address as the lookup and 
> optionally a VLAN. You can control learning and flooding.
> c) it has vlan filtering capabilities which you can turn on/off. The
> vlan capability to sellect PVIDs is also built in.
> d) It has multicast snooping
> 
> I think your model needs #a and #b, you can ignore the rest.
> I am not quiet sure how vlan port membership will apply; an fdb for
> each entry will have a vlan. You could also create one bridge per vlan
> (not the best  approach) - ccing Vlad and Stephen.
I still don't understand how this is supposed to work with the kind of
switches that we're supporting with swconfig.

A typical switch has something like 5-8 ports (+ one port that goes to
the CPU), and handles the entire forwarding path on its own. It usually
allows creating VLANs and assigning ports to them (tagged, untagged),
but many (probably most) switches do not support controlling the
forwarding path via a MAC address based FDB.

Many also do not have support for a packet header to indicate the
incoming/outgoing switch port, so creating one netdev per port will work
only for link status, not for the data path.

- Felix
