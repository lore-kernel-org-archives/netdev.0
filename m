From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [RFC] meta ematch
Date: Sun, 16 Jan 2005 19:47:51 +0100
Message-ID: <20050116184751.GY26856@postel.suug.ch>
References: <20050110211747.GA26856@postel.suug.ch> <1105394738.1085.63.camel@jzny.localdomain> <20050113174111.GP26856@postel.suug.ch> <41E6C3E5.2020908@trash.net> <20050113192047.GQ26856@postel.suug.ch> <41E71CC4.3020102@trash.net> <20050114151407.GR26856@postel.suug.ch> <1105891871.1097.647.camel@jzny.localdomain> <20050116163212.GW26856@postel.suug.ch> <1105895936.1090.717.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1105895936.1090.717.camel@jzny.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* jamal <1105895936.1090.717.camel@jzny.localdomain> 2005-01-16 12:18
> On Sun, 2005-01-16 at 11:32, Thomas Graf wrote:
> > Not really as long as iproute2 uses the same byte ordering. It has the
> > same issues as all other rtnetlink users.
> 
> wont harm to do a quick test if you have hardware. pedit for example 
> still has some occasional issues some issues with big endian which i
> havent had time to chase.

Uhmm.. yes. The endianess comes in at sutff like skb->protocol. Leaving
it to userspace makes comparison beyond simple equals quite difficult.
Providing a method to transform in kernel space adds more complexity.


> > > > +	return (v + (FIXED_1/200)) >> FSHIFT;
> > > 
> > > 200 has some magic connotation to it - a define somewhere perhaps?
> > 
> > I coped this from the code for procfs ;->
> 
> know why they have that number? It must have some significance - or
> maybe someone just stuck their hand in the air and measured 200? ;->

It is some kind of factor and has almost no impact in our case because
it only changes the first 4 bits in the exp part and I'm only interested
in the integer part. It might be a good idea to take a few bits in from
the exp part and provide the load as *10^n where n is either 2 or 3,
i.e. a load of 1.9 would be 190. I have to think a little more about
this.
