From: Marc Singer <elf@buici.com>
Subject: Re: [RFC] ip / ifconfig redesign
Date: Mon, 5 Dec 2005 12:56:13 -0800
Message-ID: <20051205205613.GB20824@buici.com>
References: <200512022253.19029.a1426z@gawab.com> <200512031646.45332.a1426z@gawab.com> <4391E4FC.1040200@candelatech.com> <20051205140057.GC24764@tuxdriver.com> <20051205174010.GA14101@buici.com> <43947FEB.7020504@unfix.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Greear <greearb@candelatech.com>, Al Boldi <a1426z@gawab.com>,
	netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <linux-net-owner@vger.kernel.org>
To: Jeroen Massar <jeroen@unfix.org>
Content-Disposition: inline
In-Reply-To: <43947FEB.7020504@unfix.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 05, 2005 at 06:59:07PM +0100, Jeroen Massar wrote:
> Marc Singer wrote:
> > On Mon, Dec 05, 2005 at 09:01:00AM -0500, John W. Linville wrote:
> >> On Sat, Dec 03, 2005 at 10:33:32AM -0800, Ben Greear wrote:
> <SNIP>
> >> The association between IP addresses and links is already a bit murky.
> >> Reference the arp_announce sysctl for what I mean.  I recall Dave M.
> >> emphasizing on at least one occassion that IP addresses belong to
> >> the _box_, not to the link.
> >
> > Precisely the case.  It should be the case that a box response to an
> > arp on *any* interface for *any* IP address known to the box.
> 
> Thus you have the following nice setup:
> 
> 10.100.10.0/24 = 10Gbit streaming network
> 10.100.20.0/24 = 10mbit admin network
> 
> 10.100.10.1 on eth0
> 10.100.20.1 on eth2
> 
> Then some idiot misconfigures his client box, putting 10.100.10.42/24 on
> the NIC that is supposed to be in the admin network only.
> Suddenly your 10mbit link is full because the arp's get answered on this
> link.

Huh?  The arp requests don't establish routing and they aren't a
significant source of traffic.  Besides, all I suggested is that if a
machine receives an arp request on eth2 for an address it has on
10.100.10/24, it should answer with it's MAC address on eth2.  

My readings of the RFC do not address this issue directly.  My
understand of this behaviour is from a discussion with someone
regarding iptables.

Moreover, if you allow users to willy-nilly connect to your networks,
you've got a completely different kind of problem on your hands.
