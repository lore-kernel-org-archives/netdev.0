From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next RFC v2 0/6] introduce infrastructure for support
 of switch chip datapath
Date: Thu, 27 Mar 2014 17:20:48 +0000
Message-ID: <20140327172048.GC13573@casper.infradead.org>
References: <1395851472-10524-1-git-send-email-jiri@resnulli.us>
 <53334A3F.6020105@mojatatu.com>
 <20140327072107.GC2845@minipsycho.orion>
 <5333FD12.9060404@mojatatu.com>
 <20140327110223.GA1615@casper.infradead.org>
 <CAGVrzcYE9uuD0Gxd5-OND4p5ieikYFchhpBm=ZiK5GaMqiQVyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>,
	dev <dev@openvswitch.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:35458 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756775AbaC0RUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 13:20:51 -0400
Content-Disposition: inline
In-Reply-To: <CAGVrzcYE9uuD0Gxd5-OND4p5ieikYFchhpBm=ZiK5GaMqiQVyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/27/14 at 09:27am, Florian Fainelli wrote:
> 2014-03-27 4:02 GMT-07:00 Thomas Graf <tgraf@suug.ch>:
> > There is definitely need beyond an ndo that is capable of
> > adding flows. You mention routes. Another example would be
> > devices capable of offloading iptables & nft rules.
> 
> Those devices usually require (at least for Broadcom) an entity
> identifying the flows and uploading flows offloading rules to the
> hardware. Although I do not think it hurts to keep those in mind to
> come up with the right design, my feeling is that they will require
> more intrusive modifications at the socket, route and forwarding path
> level if we want the Linux kernel to offer a consistent API across
> different hardware variations.

I absolutely agree. This is where the challenging bits start to
appear ;-) I don't want to speak for Jiri but my understanding is
that the flow focused approach early on is entirely because it is
the easiest case to solve. Taking OVS as an example has the
advantage of already being guarded by OpenFlow abstraction which
by nature is very device oriented.

> It is not clear to me at this point whether we want those special
> offloading devices to appear as separate net_device with specific
> flags to advertise their offloading features (NAT, IP routing...) or
> something else?

One lesson that could serve as an example which differs from TOE is
the offloading provided by recent FC HBAs. The device looks like a
regular SCSI device to the kernel but offers a full DCB engine to
allow for FCoE. The DCB bits can and must be configured. By not
representing that engine with a net_device we cannot configure the
engine through the Netlink interface dcbnl. dcbnl can certainly be
extended to allow taking a scsi id of some sort instead of a ifindex
but it's far from ideal.

My take on this is that if it makes sense to use rtnl or ethtool
to configure these offload engines then let's just go with a
globally visible net_device and improve our capabilities system.

> > But wouldn't you want to introduce an additional ndo to
> > cover these?
> 
> I would start with making sure everyone is on the same page regarding
> switches before we start building the conversation on NAT/IP-routing
> offloading, but it is good that you mention it.

Agreed
