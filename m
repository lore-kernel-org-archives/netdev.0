From: jamal <hadi@cyberus.ca>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 09 Jun 2005 18:20:36 -0400
Message-ID: <1118355636.12573.32.camel@localhost.localdomain>
References: <468F3FDA28AA87429AD807992E22D07E0450C01F@orsmsx408>
	 <20050607.132159.35660612.davem@davemloft.net>
	 <Pine.LNX.4.62.0506071852290.31708@ladlxr>
	 <20050607.204339.21591152.davem@davemloft.net>
	 <1118237775.6382.34.camel@localhost.localdomain>
	 <Pine.LNX.4.62.0506091406590.10396@ladlxr>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        "Ronciak, John" <john.ronciak@intel.com>, shemminger@osdl.org,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, mchan@broadcom.com,
        buytenh@wantstofly.org, jdmason@us.ibm.com, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
In-Reply-To: <Pine.LNX.4.62.0506091406590.10396@ladlxr>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-09-06 at 14:37 -0700, Jesse Brandeburg wrote:

> Okay let me clear this up once and for all, here is our test setup:
> 
> * 10 1u rack machines (dual P3 - 1250MHz), with both windows and linux 
> installed (running windows now)
> * Extreme 1gig switch
> * Dual 2.8 GHz P4 server, RHEL3 base, running 2.6.12-rc5 or supertso patch
> 
> * the test entails transferring 1MB files of zeros from memory to memory, 
> using TCP, with each client doing primary either send or recv, not both.

Linux as sender?

> > Even if they did have some smart ass thing in the middle that reorders,
> > it is still suprising that such a fast CPU cant handle a mere one Gig of
> > what seems to be MTU=1500 bytes sized packets.
> 
> It can handle a single thread (or even 6) just fine, its after that we get 
> in trouble somewhere.
> 

Certainly interesting details?

> > I suppose a netstat -s would help for visualization in addition to those
> > dumps.
> 
> Okay I have that data, do you want it for the old tso, supertso, or no tso 
> at all?
> 

hrmph - dont know. Dave could tell you.
I would say whatever you are running thats latest and greatest and
causes you trouble?

> > Heres what i am deducing from their data, correct me if i am wrong:
> > ->The evidence is that something is expensive in their code path (duh).
> 
> Actually I've found that adding more threads (10 total) sending to the 
> server, while keeping the transmit thread count constant yields an 
> increase our throughput all the way to 1750+ Mb/s (with supertso)
> 

Interesting tidbit

> > -> Whatever that expensive thing code is, it not helped by them
> > replenishing the descriptors after all the budget is exhausted since the
> > descriptor departure rate is much slower than packet arrival.
> 
> I'm running all my tests with the replenish patch mentioned earlier in 
> this thread.
> 

Ok. When i said " in the data path" - it could be anything from the
driver all the way to the socket.
If you have some pig along that path - it would mean you get back less
often to replenish the descriptors.

> > ---> This is why they would be seeing that the reduction of weight
> > improves performance since the replenishing happens sooner with a
> > smaller weight.
> 
> seems like we're past the weight problem now, should i start a new thread?
> 

I think so. 

> > ------> Clearly the driver needs some fixing - if they could do what
> 
> I'm not convinced it is the driver that is having issues.  We might be 
> having some complex interaction with the stack, but I definitely think we 
> have a lot of onion layers to hack through here, all of which are probably 
> relevant.
> 

I agree. But the driver could have some improvement as well if you did
what the other driver does ;->


> I have profile data, here is an example of 5tx/5rx threads, where the 
> throughput was 1236Mb/s total, 936tx, 300rx, on 2.6.12-rc5 with old TSO 
> (the original problem case) we are at 100% cpu and generating 3289 ints/s, 
> with no hardware drops reported prolly due to my replenish patch

Hrm, reading Stephen email as well ;->
Can you turn off netfilter off totaly? Most importantly remove
contracking.

cheers,
jamal
