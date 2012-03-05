From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Mon, 5 Mar 2012 17:53:39 +0100
Message-ID: <20120305165339.GS12271@wantstofly.org>
References: <1328887111.2075.43.camel@mojatatu>
 <4F39287F.6030204@intel.com>
 <1329225526.2806.34.camel@mojatatu>
 <4F3AAE80.4040609@intel.com>
 <1329315057.4158.15.camel@mojatatu>
 <4F3C5B44.7000608@intel.com>
 <1329488932.2272.19.camel@mojatatu>
 <4F3E8A01.5000205@intel.com>
 <1329568900.3027.0.camel@mojatatu>
 <4F4DAC26.4050108@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jhs@mojatatu.com, jamal <hadi@cyberus.ca>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Chris Healy <chealy@imsco-us.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4F4DAC26.4050108@intel.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 28, 2012 at 08:40:06PM -0800, John Fastabend wrote:

> Also if there are embedded switches with learning capabilities they
> might want to trigger events to user space. In this case having
> a protocol type makes user space a bit easier to manage. I've
> added Lennert so maybe he can comment I think the Marvell chipsets
> might support something along these lines. The SR-IOV chipsets I'm
> aware of _today_ don't do learning. Learning makes the event model
> more plausible.

net/dsa currently configures any switch chips in the system to do
auto-learning.  However, I would much prefer to disable that, and have
the switch chip just pass up packets for new source addresses, have
Linux do the learning, and then mirror the Linux software FDB into
the hardware instead -- that avoids having to manually flush the
hardware FDB on certain STP state transitions or having to configure
the hardware to use a shorter address learning timeout when we're in
the middle of an STP topology change, which are problems we are
running into in practice.

Just curious -- while your patches allow propagating FDB entries
into the hardware, do you also have hooks to tell the hardware which
ports are to share address databases?

For net/dsa, we currently have:

	http://patchwork.ozlabs.org/patch/16578/

While I think this is conceptually sound, the implementation is hacky,
and I wonder how you've solved it for your setup, and if DSA can
piggy-back off that.
