From: jamal <hadi@cyberus.ca>
Subject: Re: IPsec performance
Date: Wed, 04 May 2005 07:34:37 -0400
Message-ID: <1115206478.7665.100.camel@localhost.localdomain>
References: <Pine.GSO.4.58.0505022117190.25766@kekkonen.cs.hut.fi>
	 <Pine.GSO.4.58.0505022204090.25766@kekkonen.cs.hut.fi>
	 <Pine.LNX.4.62.0505030248020.26815@kaber.coreworks.de>
	 <Pine.GSO.4.58.0505030820160.24686@kekkonen.cs.hut.fi>
	 <1115099678.2953.3.camel@ori.thedillows.org>
	 <Pine.GSO.4.58.0505030943310.247@kekkonen.cs.hut.fi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Dave Dillow <dave@thedillows.org>, Patrick McHardy <kaber@trash.net>,
        Netdev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Miika Komu <miika@iki.fi>
In-Reply-To: <Pine.GSO.4.58.0505030943310.247@kekkonen.cs.hut.fi>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2005-03-05 at 09:44 +0300, Miika Komu wrote:
> On Tue, 3 May 2005, Dave Dillow wrote:
> 
> > On Tue, 2005-05-03 at 08:25 +0300, Miika Komu wrote:
> > > However, this does explain why I got only 1.9 megabytes/s with 3DES.
> >
> > What was your hardware? Without knowing what you're running on, it's
> > impossible to tell if that is good or bad.
> >
> > Linux Journal was getting ~5.5MB/s on a PIV 2.2GHz.
> > I get ~2.1MB/s on a 550MHz Athlon.
> 
> Intel Pentium III 500 MHz

I tested on 2.4.x based on Davems code backport and contribution from
Herbert > a year ago on a really bad Xeon 2.0Ghz(?), 32 bit bus mboard,
e1000 NIC. I used a 2.4.x kernel because i was trying to compare against
a broadcom SB1250 board which couldnt run 2.6.x - I also had to do a few
tricks to get it to run/compile on MIPS and so may have contributed to
perfomance degradation. 
In any case, the numbers between those two were not very different (even
though the sb1250 was at i think 600Mhz). Unfortunately i lost the
loaner sb1250 shortly after (it was fun to play with). I have my full
results somewhere in another machine which i can lookup, but heres some
summary data i had in my laptop:

used:
A) i) two flows ii) 4 flows iii) 8 flows
all seem to reproduce the same aggregate throughput. 

B) static keying


Tests and results
-----------------

I: Transport mode:

1) Message Authentication: tested with hmac-md5
Should have done sha-1. Next time.

a) 64 byte packets
Input 100Mbps (148.8Kpps) output 112 Kpps

This is about 75% of wire rate (75Mbps).

b) 1400 byte packets
8712 (99% of wire rate) == about 17.4Kpps which is almost
wire rate at 200Mbps at that packet size.
Note we can never get 100% wire rate since the packet header grows
because of the AH insertion.

2) Data encryption mode: 3DES/md5

a) 64 byte packets
Peak achievement:
43Kpps == 30Mbps.

b) 1400 byte packets
Peak achievement:
1.8Kpps == 20Mbps.

Now this result is very interesting. It clearly shows that 3DES
is compute intensive i.e as the packet grows you get slower - quiet
counterintuitive. 
An encryption chip would go along way to help with large packet sizes.
Another observation:
In other words given the synchronous nature of the crypto path, there is
a threshold value where it may be valuable to use a crypto chip.
The effects of this were actually demonstrated by Eugene Surovegin
<ebs@ebshome.net>; long thread of discussion on this on netdev.

We need to find the threshold packet size where encryption starts
overtaking general packet processing i.e where offloading becomes
interesting if we stick with sync scheme.

Another thing for s/ware based crypto is to improve the 3DES
implementation as in assembler coding.

Iam back on/off playing with this, so expect more results Real Soon Now.


cheers,
jamal
