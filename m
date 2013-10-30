From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 30 Oct 2013 10:56:16 -0700
Message-ID: <52714840.2030809@intel.com>
References: <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com> <526D6EBA.3020903@openwrt.org> <526EEAE9.6090508@mojatatu.com> <20131030172756.GM8570@wantstofly.org> <20131030173416.GA32234@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jamal Hadi Salim <jhs@mojatatu.com>,
	Felix Fietkau <nbd@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chris Healy <cphealy@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:56512 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751970Ab3J3R4h (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 13:56:37 -0400
In-Reply-To: <20131030173416.GA32234@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/30/2013 10:34 AM, Lennert Buytenhek wrote:
> On Wed, Oct 30, 2013 at 06:27:56PM +0100, Lennert Buytenhek wrote:
>
>>>> This means that all per-port netdevs will be dummy ports which don't
>>>> include the data path.
>>
>> And I think that's fine.
>>
>> Look, even if you're not going to address data traffic to individual
>> ports on your switch chip, there's still a plethora of per-port
>> operations that you want to be able to do: administratively setting
>> the link state on ports up and down, controlling autonegotiation and
>> other PHY settings on individual ports, etc.
>>
>> You can either let the administrator do this with the standard ifconfig
>> / ip link / ethtool tools, or you can make up a parallel API and
>> corresponding set of userland tools to duplicate most of the existing
>> functionality -- I know which option I prefer.
>>
>> Presenting each switch port as an individual Linux netdevice to the OS
>> is an orthogonal decision to actually using those netdevices for data
>> traffic, and conflating the two by arguing that you need special tools
>> to do per-port operations for the sole reason that your switch chip
>> cannot address individual ports is a rather confused argument.
>
> Forgot to add: there's a patch for net/dsa that adds exactly such an
> option.  We called it 'unmanaged' mode, and it doesn't enable packet
> tagging on the CPU<->switch chip interface, so that data only ever
> flows over a single network interface ("eth0"), while the other
> ("dummy") network interfaces ("port1", "port2", etc) are used for
> setting link state with ip link, setting PHY settings with ethtool,
> getting ethtool statistics, etc, with 100% unmodified userland tools.
> This patch is currently buried inside a vendor tree, but I'd be happy
> to dig it out and submit it.
>

A "dummy" network interface is something I've been thinking about
for SR-IOV as well. In the SR-IOV case we have an embedded bridge
in the hardware but the virtual functions may be direct assigned
to a guest and not visible to the host.

It would be easier to manage the ports and assign them to different
bridge/QOS objects (OVS, bridge, nftables) if the ports were visible
and manageable in the host even though there is no data path. Today
we special ndo ops that only work for VFs but this is a bit clumsy
and gets more clumsy as the nic switch becomes more like a real switch.

.John
