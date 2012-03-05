From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Mon, 5 Mar 2012 18:00:44 +0100
Message-ID: <20120305170044.GT12271@wantstofly.org>
References: <4F3C5B44.7000608@intel.com>
 <1329488932.2272.19.camel@mojatatu>
 <4F3E8A01.5000205@intel.com>
 <1329568900.3027.0.camel@mojatatu>
 <4F4DAC26.4050108@intel.com>
 <1330523779.18226.17.camel@mojatatu>
 <4F4E5FA4.4040506@intel.com>
 <20120229095204.48885405@nehalam.linuxnetplumber.net>
 <4F4E6C44.9070502@intel.com>
 <1330608980.6944.27.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Chris Healy <chealy@imsco-us.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:61263 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963Ab2CERAq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2012 12:00:46 -0500
Content-Disposition: inline
In-Reply-To: <1330608980.6944.27.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 01, 2012 at 08:36:20AM -0500, Jamal Hadi Salim wrote:

> > > I want to see a unified API so that user space control applications (RSTP, TRILL?)
> > > can use one set of netlink calls for both software bridge and hardware offloaded
> > > bridges.  Does this proposal meet that requirement?
> > > 
> 
> I dont see any issues with those requirements being met.
> 
> > Jamal, so why do "They have to be different calls"? I'm not so sure anymore...
> > moving to RTM_FDB_XXXENTRY saved some refactoring in the bridge module but that
> > is just cosmetic.
> 
> I may not want to use the s/ware bridge i.e I may want to use h/ware
> bridge. I may want to use both.

This is a rather common case in embedded wireless routers/access points,
where you want to have the 4 LAN ports bridged together with the wlan0
interface.

In this scenario, the bridging between the LAN ports is typically done
in hardware, and the bridging between the LAN ports and wlan0 in
software, but here you have to be careful when you send the packet from
the switch chip up the stack to be forwarded to the wlan0 interface to
not re-send it to the hardware switch chip ports other than the one
that the packet came from.

net/dsa currently solves this by not having the hardware handle
broadcast packets at all, which circumvents the problem, but for
multicast traffic you would still like to be able to do at least the
forwarding that can be done in hardware in hardware.  (Unicast doesn't
have this problem as long as the kernel and the switch chip agree on
their view of the FDB.)
