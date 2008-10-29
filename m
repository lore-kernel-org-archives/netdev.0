From: almaop@poczta.fm
Subject: Re: New filter 'flow' bug?
Date: 29 Oct 2008 15:09:05 +0100
Message-ID: <20081029140905.586E4E4357B@f11.poczta.interia.pl>
Mime-Version: 1.0
Content-Type: TEXT/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: David Miller <davem@davemloft.net>,
	"linux-net@vger.kernel.org" <linux-net@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>,
	"almaop@poczta.fm" <almaop@poczta.fm>
Return-path: <linux-net-owner@vger.kernel.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > From: almaop@poczta.fm
> > Date: 29 Oct 2008 08:27:05 +0100
> >> My configuration: gentoo, kernel 2.6.26.7 + imq patch + l7 patch, glibc
> 2.7, iproute2 2.6.26. Shaping is done on ethernet (e1000 card) but as I see
> on the ifb nothing changes.
> >> There are htb 3 classes with sfq as their qdiscs. It is simple,
> something like:
> >>
> >> tc qdisc add dev $DEV root handle 1: htb default 4 tc class add dev
> $DEV parent 1: classid 1:1 htb rate 78kbps ceil 78kbps overhead 0 linklayer
> atm
> >>
> >> tc class add dev $DEV parent 1:1 classid 1:2 htb rate 20kbps ceil
> 20kbps overhead 0 linklayer atm prio 3
> >> tc class add dev $DEV parent 1:1 classid 1:3 ...
> >> tc class add dev $DEV parent 1:1 classid 1:4 ...
> >>  
> >> tc qdisc add dev $DEV parent 1:2 handle 2: sfq quantum 64
> >> tc qdisc add dev $DEV parent 1:3 handle 3: sfq
> >> tc qdisc add dev $DEV parent 1:4 handle 4: sfq
> >>
> >> tc filter add dev $DEV parent 1: ....
> >> ....
> >>  
> >> tc filter add dev $DEV parent 2: protocol ip handle 1 prio 12 flow 
> >> hash keys dst,proto,proto-dst divisor 128
> >>
> >> tc filter add dev $DEV parent 3: protocol ip handle 1 prio 12 flow 
> >> hash keys dst,proto,proto-dst divisor 128
> >>
> >> tc filter add dev $DEV parent 4: protocol ip handle 1 prio 12 flow 
> >> hash keys nfct-src,nfct-dst,proto,nfct-proto-src,nfct-proto-dst divisor
> 128
> >>
> >> I'm not sure where is the bug - in the flow filter or in the sfq
> qdisc.
> 
> Which SFQ qdisc is stalling?
> 
Thanks for reply.
So I've done few tests. I've removed quantum 64 (it  was qdisc with small packets). It made no difference. It looks like the key is the first sfq qdisc (tc qdisc add dev $DEV parent 1:2 handle 2: sfq - in my example). When there is no traffic in this qdisc for about 45 seconds (shorter time when there is no traffic at all on the interface) - it stalls. Other qdiscs stall also. So there is no packet flow on that interface. Removing filters ('flow' filters) does'nt help. I have to remove (all) sfq qdiscs. And then the traffic is resumed.
Regards.

Krzysiek


