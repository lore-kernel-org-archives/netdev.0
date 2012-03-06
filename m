From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into
 hardware
Date: Tue, 06 Mar 2012 08:42:26 -0500
Message-ID: <1331041346.2374.108.camel@mojatatu>
References: <1328887111.2075.43.camel@mojatatu> <4F39287F.6030204@intel.com>
	 <1329225526.2806.34.camel@mojatatu> <4F3AAE80.4040609@intel.com>
	 <1329315057.4158.15.camel@mojatatu> <4F3C5B44.7000608@intel.com>
	 <1329488932.2272.19.camel@mojatatu> <4F3E8A01.5000205@intel.com>
	 <1329568900.3027.0.camel@mojatatu> <4F4DAC26.4050108@intel.com>
	 <20120305165339.GS12271@wantstofly.org>
Reply-To: jhs@mojatatu.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Chris Healy <chealy@imsco-us.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <20120305165339.GS12271@wantstofly.org>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-03-05 at 17:53 +0100, Lennert Buytenhek wrote:

> net/dsa currently configures any switch chips in the system to do
> auto-learning.  

So we clearly need the (user configurable) knob to turn on/off learning.
I think it should also be upto the admin to decide whether the learning
happens in the kernel or user space.
 
> However, I would much prefer to disable that, and have
> the switch chip just pass up packets for new source addresses, have
> Linux do the learning, and then mirror the Linux software FDB into
> the hardware instead -- that avoids having to manually flush the
> hardware FDB on certain STP state transitions or having to configure
> the hardware to use a shorter address learning timeout when we're in
> the middle of an STP topology change, which are problems we are
> running into in practice.

So in the scenario you are describing then it seems the h/ware has
no stp state toggles, correct? In other ASICs i have seen, there is
influence from stp state on behavior.

> Just curious -- while your patches allow propagating FDB entries
> into the hardware, do you also have hooks to tell the hardware which
> ports are to share address databases?

I think those are missing in this discussion and makes a lot of sense to
be part of the interface.

> net/dsa currently solves this by not having the hardware handle
> broadcast packets at all, which circumvents the problem, but for
> multicast traffic you would still like to be able to do at least the
> forwarding that can be done in hardware in hardware.  (Unicast doesn't
> have this problem as long as the kernel and the switch chip agree on
> their view of the FDB.)

Of course this could represent an interesting opportunity for a DOS.
Even at 4 port switch at 100Mbs, hitting 500Kpps to the CPU (I am
thinking these tiny switches end up in some tiny MIPS/ARM cpu) could
be devastating. How do you deal with that?

cheers,
jamal


