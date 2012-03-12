From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Mon, 12 Mar 2012 09:48:50 +0100
Message-ID: <20120312084850.GB28523@wantstofly.org>
References: <1329315057.4158.15.camel@mojatatu>
 <4F3C5B44.7000608@intel.com>
 <1329488932.2272.19.camel@mojatatu>
 <4F3E8A01.5000205@intel.com>
 <1329568900.3027.0.camel@mojatatu>
 <4F4DAC26.4050108@intel.com>
 <20120305165339.GS12271@wantstofly.org>
 <1331041346.2374.108.camel@mojatatu>
 <20120306140957.GA27559@wantstofly.org>
 <1331129500.2237.72.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: John Fastabend <john.r.fastabend@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com, Chris Healy <chealy@imsco-us.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1331129500.2237.72.camel@mojatatu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 07, 2012 at 09:11:40AM -0500, Jamal Hadi Salim wrote:

> > Why so?  (I think the switch chips should just never do learning at
> > all..)
> 
> I agree that learning in software gives you more flexibility;
> however, I am for providing interface flexibility as well - switches
> have learning features. I think i should be able to use them when it
> makes sense to. 

Since it can lead to problems (address database mismatches, doesn't
correctly handle STP transitions or topology changes automatically),
I think it should be avoided whenever possible.  I don't see any
advantages of hardware based learning over software based learning
anyway ('flexibility' doesn't seem like a very good argument).


> > > I think it should also be upto the admin to decide whether the
> > > learning happens in the kernel or user space.
> > 
> > I can't see any point in doing it in userspace.  What would be the
> > advantage of that?  And based on what would the admin make the decision?
> 
> If i wanted to do some funky access control based on some new MAC
> address showing up - best place to do it is user space.

Alright, that sounds fair.


> > Keep in mind that these chips also do VLAN tagging in hardware, and
> > so a scenario like:
> > 
> > 	# brctl addbr br123
> > 	# brctl addif br123 lan1.123
> > 	# brctl addif br123 lan2.123
> > 
> > is also one that can be handled in hardware (which the current
> > patchwork patch doesn't handle yet).
> 
> We would need to work with offloading VLANs, no?

Yes.


> Do the current VLAN offloads used for NICs suffice for switching
> chips as well?  i.e typically most chips have a table associated
> with some port in which the Vlan is partof or is the lookup key. 

It should be doable along the lines of the current DSA patch --
add a VLAN ID argument to the interface add/remove callbacks, and
when a VLAN virtual interface is added to the bridge, call the
relevant callbacks with the parent interface + VLAN ID instead.
(This doesn't work for stacked VLANs, but the current net/dsa
supported chips don't handle those anyway.)
