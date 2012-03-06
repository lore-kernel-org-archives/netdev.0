From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Tue, 6 Mar 2012 15:15:51 +0100
Message-ID: <20120306141551.GB27559@wantstofly.org>
References: <1329225526.2806.34.camel@mojatatu>
 <4F3AAE80.4040609@intel.com>
 <1329315057.4158.15.camel@mojatatu>
 <4F3C5B44.7000608@intel.com>
 <1329488932.2272.19.camel@mojatatu>
 <4F3E8A01.5000205@intel.com>
 <1329568900.3027.0.camel@mojatatu>
 <4F4DAC26.4050108@intel.com>
 <20120305165339.GS12271@wantstofly.org>
 <4F558852.6050006@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, jamal <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Chris Healy <chealy@imsco-us.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:62915 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758612Ab2CFOPx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Mar 2012 09:15:53 -0500
Content-Disposition: inline
In-Reply-To: <4F558852.6050006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 05, 2012 at 07:45:22PM -0800, John Fastabend wrote:

> >> Also if there are embedded switches with learning capabilities they
> >> might want to trigger events to user space. In this case having
> >> a protocol type makes user space a bit easier to manage. I've
> >> added Lennert so maybe he can comment I think the Marvell chipsets
> >> might support something along these lines. The SR-IOV chipsets I'm
> >> aware of _today_ don't do learning. Learning makes the event model
> >> more plausible.
> > 
> > net/dsa currently configures any switch chips in the system to do
> > auto-learning.  However, I would much prefer to disable that, and have
> > the switch chip just pass up packets for new source addresses, have
> > Linux do the learning, and then mirror the Linux software FDB into
> > the hardware instead -- that avoids having to manually flush the
> > hardware FDB on certain STP state transitions or having to configure
> > the hardware to use a shorter address learning timeout when we're in
> > the middle of an STP topology change, which are problems we are
> > running into in practice.
> 
> Great. And the plan is we should be able to use the same daemon with
> minimal changes (currently a flag) to control both sw and hw bridges.

Why should userspace care at all whether there is a hw bridge present?


> > Just curious -- while your patches allow propagating FDB entries
> > into the hardware, do you also have hooks to tell the hardware which
> > ports are to share address databases?
> 
> Not in the current patches. I don't have hardware right now
> that can instantiate multiple bridges. When I get some I was hoping
> to do something similar to this patch and use netlink commands
> to create/delete bridges and add/remove ports to them. This would
> be modifying the existing commands to work for both software and
> hardware bridges.

In the DSA h/w bridging patch, a hardware address database is only
allocated on addif to an existing bridge, not on addbr.

For one, at addbr time, you have no idea yet whether there will
be any switch chip ports in the bridge port group for this bridge.

Also, the h/w has some restrictions on the assignment of address
database identifiers (e.g. if you want to bridge between lan1.123
and lan2.123, you have to use address database identifier '123').


> By a bridge instantiation I mean a shared address database in this case.

Makes sense.  (I'd add STP port states to this.)
