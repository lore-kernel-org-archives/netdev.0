From: bert hubert <ahu@ds9a.nl>
Subject: Re: TCP/IPv6 broken in Linux 2.5.64?
Date: Tue, 18 Mar 2003 17:51:24 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030318165124.GA10127@outpost.ds9a.nl>
References: <20030318131104.GA16367@hensema.net> <20030318162532.GA9705@outpost.ds9a.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Erik Hensema <erik@hensema.net>, netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20030318162532.GA9705@outpost.ds9a.nl>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Mar 18, 2003 at 05:25:32PM +0100, bert hubert wrote:

> So we have:
> 
>        to:	2.4.18	2.5.65
> from:
> 2.4.18		  OK     OK
> 2.5.65  	  OK     ERROR

Ok, here is a counter example of 2.5.65 happily talking to 2.5.65, so it
sometimes does work:

33.933107 hostC.33255 > hostB.22: SWE 3663286543:3663286543(0) win 5680 
	<mss 1420,sackOK,timestamp 19198944 0,nop,wscale 0>
33.933203 hostB.22 > hostC.33255: S 3554639364:3554639364(0) ack 3663286544 
	win 5712 <mss 1440,sackOK,timestamp 15793123 19198944,nop,wscale 0>
33.999407 hostC.33255 > hostB.22: . ack 1 win 5680 
	<nop,nop,timestamp 19199006 15793123>
34.007239 hostB.22 > hostC.33255: P 1:41(40) ack 1 win 5712 
	<nop,nop,timestamp 15793197 19199006>
34.072108 hostC.33255 > hostB.22: . ack 41 win 5680 
	<nop,nop,timestamp 19199081 15793197>
34.091633 hostC.33255 > hostB.22: P 1:40(39) ack 41 win 5680
	<nop,nop,timestamp 19199081 15793197>
34.097058 hostB.22 > hostC.33255: . ack 40 win 5712 
	<nop,nop,timestamp 15793286 19199081>

Here is a macos X laptop, hostD trying and failing talk to hostB, which runs
2.5.65:

16.829237 hostD.56023 > hostB.22: S 3755233012:3755233012(0) win 32768
	<mss 1440,nop,wscale 0,nop,nop,timestamp 3371673393 0>
16.829482 hostB.22 > hostD.56023: S 3776737964:3776737964(0) ack 3755233013 
	win 5712 <mss 1440,nop,nop,timestamp 6571699 3371673393,nop,wscale 0>
17.296953 hostD.56023 > hostB.22: . ack 1 win 32844 
	<nop,nop,timestamp 3371673394 6571699>
17.301934 hostB.22 > hostD.56023: P 1:41(40) ack 1 win 5712
	<nop,nop,timestamp 6572172 3371673394>
18.953105 hostB.22 > hostD.56023: P 1:41(40) ack 1 win 5712
	<nop,nop,timestamp 6573824 3371673394>
21.768126 hostB.22 > hostD.56023: P 1:41(40) ack 1 win 5712
	<nop,nop,timestamp 6576640 3371673394>
27.398163 hostB.22 > hostD.56023: P 1:41(40) ack 1 win 5712
	<nop,nop,timestamp 6582272 3371673394>

Closer inspection shows:
17:47:39.206188 HostB.22 > HostD.56030: P [bad tcp cksum 407f!] 1:41(40)
ack 1 win 5712 <nop,nop,timestamp 6894188 3371674038> (len 72, hlim 64)

Note the bad checksum! It appears hostB is the culprit here, the one
constant factor in the entire story. HostB is a Pentium PRO, the other
machines aren't. Perhaps this might be it?

This dump was run on hostB, so no chance of bad media there.

Let me know if I can do more research - icmp6 works just fine.

Regards,

bert

-- 
http://www.PowerDNS.com      Open source, database driven DNS Software 
http://lartc.org           Linux Advanced Routing & Traffic Control HOWTO
http://netherlabs.nl                         Consulting
