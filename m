From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: Re: [patch 2/4] ipset: make IPv4 and IPv6 address handling similar
Date: Tue, 18 Jan 2011 22:43:43 +0100
Message-ID: <20110118214343.GA4845@mail.eitzenberger.org>
References: <20110118142154.697547841@eitzenberger.org> <20110118142247.498399684@eitzenberger.org> <alpine.DEB.2.00.1101182116150.28203@blackhole.kfki.hu> <alpine.LNX.2.01.1101182121310.19007@obet.zrqbmnf.qr> <alpine.DEB.2.00.1101182128210.28350@blackhole.kfki.hu> <alpine.LNX.2.01.1101182139030.19166@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.01.1101182139030.19166@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 18, 2011 at 09:39:32PM +0100, Jan Engelhardt wrote:
> On Tuesday 2011-01-18 21:37, Jozsef Kadlecsik wrote:
> >> >> 
> >> >> this does not work for AF_INET6:
> >> >> 
> >> >>  ipset add foo6 20a1:1:2:3:4:5:6:7/128
> >> >>  ipset v5.2: Syntax error: plain IP address must be supplied: 20a1:1:2:3:4:5:6:7/128
> >> >
> >> >Yeah, the usual issue: should IPv4/32 and IPv6/128 be handled as a plain 
> >> >IPv4/v6 address when the manual says "enter a plain IPv4/v6 address" :-).
> >> 
> >> (Assuming this was a question, heuristically based on the word order
> >> you used:) I don't think so. iptables, resp. its modules, do not
> >> allow that either.
> >
> >I know, but the situation is a little bit more complicated: the set type 
> >in question works differently with IPv4 and IPv6. In the IPv4 case, a 
> >range of IP addresses as IPv4/prefix is accepted as input (thus 
> >192.168.1.1/32 too), while for IPv6, only plain IPv6 addresses are allowed 
> >and therefore 20a1:1:2:3:4:5:6:7/128 was rejected.
> 
> Is there a specific reason that there is no IPv6 net support?

You shouldn't use hash:ip with ranges for IPv4 too because the range
members are added individually, which is less efficient both memory
and performance wise, see:

 $ ipset create foo hash:ip hashsize 64
 $ ipset add foo 192.168.1.0/30
 $ ipset list foo
 Name: foo
 Type: hash:ip
 Header: family inet hashsize 64 maxelem 65536 
 Size in memory: 628
 References: 0
 Members:
 192.168.1.3
 192.168.1.2
 192.168.1.0
 192.168.1.1

> Call it laziness: for IPv6, the hash:ip* types does *not* accept a 
> range of elements to be added/deleted in one command, expressed as
> 
> ipset add foo6 20a1:1:2:3:4:5:6:7/120
> 
> or
> 
> ipset add foo6 20A1:1:2:3:4:5:6:0-20A1:1:2:3:4:5:6:FF
> 
> For IPv4 the syntax is accepted and handled.

