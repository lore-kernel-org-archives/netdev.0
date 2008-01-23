From: Steven Whitehouse <swhiteho@redhat.com>
Subject: Re: My 802.3ad is my bond
Date: Wed, 23 Jan 2008 17:19:38 +0000
Message-ID: <1201108778.22038.261.camel@quoit>
References: <1201103100.22038.254.camel@quoit>  <26889.1201108405@death>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:39107 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756725AbYAWR1i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2008 12:27:38 -0500
In-Reply-To: <26889.1201108405@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Wed, 2008-01-23 at 09:13 -0800, Jay Vosburgh wrote:
> Steven Whitehouse <swhiteho@redhat.com> wrote:
> [...]
> >This commit: ece95f7fefe3afae19e641e1b3f5e64b00d5b948 seems to have
> >caused a problem with parsing bond arguments as now only the numeric
> >arguments seem to work (in modprobe.conf) and specifying 802.3ad fails.
> >When I revert that patch in my local tree all seems ok.
> 
> 	Thanks for the report; I know what the problem here is.  I'll
> get a fix out.
> 
> >Also I notice that one of my two NICs now reports this:
> >
> >bonding: bond0: link status definitely down for interface eth0,
> >disabling it
> >bonding: bond0: Interface eth0 is already enslaved!
> >bond0.5: no IPv6 routers present
> >
> >which I think is also new with this set of bonding updates, before it
> >used to use both interfaces ok. I've not worked out which of the other
> >patches causes this so far, but I can if its helpful,
> 
> 	That would be helpful, as would some more details: e.g., the
> various options passed to bonding, the complete dmesg log, contents of
> /proc/net/bonding/bond0 [or whatever your interface is called], and
> anything else you think would be helpful.
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
Ok. I'll try and work out which patch it is, but in the mean time:

Ethernet Channel Bonding Driver: v3.2.3 (December 6, 2007)

Bonding Mode: IEEE 802.3ad Dynamic link aggregation
Transmit Hash Policy: layer2 (0)
MII Status: up
MII Polling Interval (ms): 100
Up Delay (ms): 0
Down Delay (ms): 0

802.3ad info
LACP rate: slow
Active Aggregator Info:
        Aggregator ID: 1
        Number of ports: 1
        Actor Key: 17
        Partner Key: 4
        Partner Mac Address: 00:12:a9:13:3f:67

Slave Interface: eth0
MII Status: down                       <-- this one should be up as well
Link Failure Count: 2
Permanent HW addr: 00:11:43:d7:75:74
Aggregator ID: 2

Slave Interface: eth1
MII Status: up
Link Failure Count: 1
Permanent HW addr: 00:11:43:d7:75:75
Aggregator ID: 1

Bonding options:
options bond0 miimon=100 mode=802.3ad

I'll send the dmesg by private email as its quite large,

Steve.



