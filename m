From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 7/9] rhashtable: Per bucket locks & deferred
 expansion/shrinking
Date: Sat, 17 Jan 2015 11:56:23 +0000
Message-ID: <20150117115622.GA8502@acer.localdomain>
References: <20150116183626.GS30132@acer.localdomain>
 <20150116191831.GA26730@casper.infradead.org>
 <20150116193557.GU30132@acer.localdomain>
 <20150116204921.GA14833@gondor.apana.org.au>
 <20150116213156.GA7109@acer.localdomain>
 <20150117003340.GA16374@gondor.apana.org.au>
 <20150117080621.GB3968@acer.localdomain>
 <20150117093228.GA19137@gondor.apana.org.au>
 <7AE5EEE0-60C7-43B4-848A-2D952D3A6DEF@trash.net>
 <20150117101309.GA19585@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Thomas Graf <tgraf@suug.ch>,
	David Laight <David.Laight@ACULAB.COM>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"paulmck@linux.vnet.ibm.com" <paulmck@linux.vnet.ibm.com>,
	"edumazet@google.com" <edumazet@google.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"josh@joshtriplett.org" <josh@joshtriplett.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150117101309.GA19585@gondor.apana.org.au>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17.01, Herbert Xu wrote:
> On Sat, Jan 17, 2015 at 09:51:46AM +0000, Patrick McHardy wrote:
> > 
> > I agree, however at least in the case of nftables you can easily do the same thing by adding millions of rules.
> 
> I think that's a problem in itself.  If a single packet can kill
> the CPU through millions of rules, then namespaces would be a joke.
> There has to be a limit to the number of rules or the processing
> has to be deferred into thread context (thus subject to scheduler
> control) at some point.

I think that's a problem that's unrelated to netfilter. Its quite easy
to configure something that will make the network stack eat up all
the CPU, consider f.i.:

bridge name	bridge id		STP enabled	interfaces
br0		8000.625dda62a3d4	no		veth0
							veth1

Now thing of bridging, veth, TC actions, iptables, routing, all in
combination. Sure, single cases can be caught it might be possible
to restrict them, but I don't believe that in the near term we will
be able to handle this properly.

And even if all loops etc are handled, what keeps the user from
creating a million veth devices and putting them into a long
chain?

This needs to be fixed on a different level in my opinion.

> > It doesn't make things worse.
> 
> So I don't think that's a valid justification for ignoring this
> hash table problem.
