From: jamal <hadi@cyberus.ca>
Subject: Re: ipt_physdev.c alignment problems on parisc64
Date: 12 Sep 2003 08:54:29 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1063371268.1031.96.camel@jzny.localdomain>
References: <200309022116.41697.bdschuym@pandora.be>
	 <20030903200426.59d0af4a.davem@redhat.com>
	 <20030905153152.GA3623@obroa-skai.de.gnumonks.org>
	 <1063330846.1028.11.camel@jzny.localdomain>
	 <20030912085606.GC2350@obroa-skai.de.gnumonks.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
   Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
   netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030912085606.GC2350@obroa-skai.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 2003-09-12 at 04:56, Harald Welte wrote:
> On Thu, Sep 11, 2003 at 09:40:46PM -0400, jamal wrote:
> > Harald,
> > 
> > Could you not resolve all the ifindices of the said ppp+ interfaces
> > at rule installation time and do an integer compare instead?
> 
> No, this is a different semantic.  Ifindexes change when an interface
> goes down and comes up again (let's say you have a PPTP tunnel server
> which terminates a couple of ppp* interfaces).
> 

If ifindices change for the same device name then that would be a bug.
The only time they should change is if a) you reboot or b) you unload a
module after ifconfiged down the device(s) and then reload it later.
In both cases if you have exactly the same setup, the chances of those
ifindices changing are very slim.

> What could be done, is register with the netdev notifiers and then at
> every ifup/ifdown event change the ifindex[es] in all rules that use 
> this style of match.
> 

You may wanna listen to new devices being created and add to the ifindex
list. 

> This is what was done in the 2.2 ipchains code, if I am not mistaken.
> However, Rusty went for the string-compare solution while implementing
> iptables.  
> 
> Imagine somebody with lots of ppp interfaces (let's say 40)... and we
> would need to resolve all 40 into ifindexes, put them into an array...
> how big would you like to make the array?  how many interfaces do people
> have? how much space do you want to waste (dynamically reallocating this
> space while the ruleset is already loaded is not possible).
> 

This is a valid reason for the string compare given the way iptables is
architected.

> And then you have 1000 rules, each of it using a ppp* style match. than
> at every ifdown/ifup you iterate over 1000 rules, checking if you need
> to update one of the 40 ifindexes?  quite slow...

you could optimize. There can be only one ppp* list for all rules to
share and you iterate not the rules rather the table which holds the
ifindices. Could be 1-2 lookup to find the ifindex if proper hashing is
used.

cheers,
jamal
