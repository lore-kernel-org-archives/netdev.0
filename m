From: jamal <hadi@cyberus.ca>
Subject: ppp ifindex WAS(Re: ipt_physdev.c alignment problems on parisc64
Date: 21 Sep 2003 09:57:07 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1064152627.1030.128.camel@jzny.localdomain>
References: <20030912085606.GC2350@obroa-skai.de.gnumonks.org>
	 <1063371268.1031.96.camel@jzny.localdomain>
	 <20030920055002.GC8398@sunbeam.de.gnumonks.org>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>,
        Bart De Schuymer <bdschuym@pandora.be>, acme@conectiva.com.br,
        netfilter-devel@lists.netfilter.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20030920055002.GC8398@sunbeam.de.gnumonks.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 2003-09-20 at 01:50, Harald Welte wrote:

> > 
> > If ifindices change for the same device name then that would be a bug.
> > The only time they should change is if a) you reboot or b) you unload a
> > module after ifconfiged down the device(s) and then reload it later.
> > In both cases if you have exactly the same setup, the chances of those
> > ifindices changing are very slim.
> 
> What about a ppp interface that is deleted because pppd terminated.
> Then you start a new pppd that uses the same ppp interface [i.e. ppp12].
> Would ifindex still be guaranteed to be the same in that case?
> 

maybe not in that case - but i am not sure if it is a feature or a bug; 
The reason is because pppd will create a brand new device everytime but
may maintain the same name as you point out. I suppose this is legit.
The whole point behind the ifindex is to do device management, billing,
etc. Example if you were doing fault detection/failover and something
goes wrong with ppp12, you can uniqueuly identify it is the same ppp12
that you are interested in if the ifindex is the same. Chances are no if
you depend on the name as you do in iptables. Infact the new ppp12 maybe
terminating at a new server. For this reason, maybe a good idea for ppp
_not_ to reuse the same unit number but rather to monotomically
increment so that next ppp device you get is ppp13. Yes, I know it will
break a lot of scripts etc. Unless you dont care about the above
scenario.
OTOH, take eth* - in this case it is desirable to maintain the same
ifindex even across reboots for consistency as above. Note, tc doesnt
have these issues.

cheers,
jamal
