From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 12 Jan 2005 23:02:20 +0100
Message-ID: <16869.40556.711969.512311@robur.slu.se>
References: <Pine.LNX.4.44.0501071416060.5818-100000@localhost.localdomain>
	<200501121411.49293.jeremy.guthrie@berbee.com>
	<16869.34519.31321.977100@robur.slu.se>
	<200501121445.51780.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Robert Olsson <Robert.Olsson@data.slu.se>,
        Stephen Hemminger <shemminger@osdl.org>,
        Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501121445.51780.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



Jeremy M. Guthrie writes:

 > My throughput dropped from 500 mbps to 8mbps.  8(

 Weird!

 >            CPU0       CPU1
 >  18: 3586173518       1815   IO-APIC-level  eth3
 >  20:          2 2464382507   IO-APIC-level  eth2

 >            CPU0       CPU1
 >  18: 3586173518       1815   IO-APIC-level  eth3
 >  20:          2 2464387985   IO-APIC-level  eth2

 There are no irq's on eth3 at all so RX softirq is constantly running.
 Which means it's deferred to ksoftirqd now and running under scheduler 
 context. Do you have anything that competes with ksoftirqd for CPU0 on 
 your system?
 It used be recommended to increase the priority of ksoftirqd but I wonder 
 what's going on your system. We see interrupts on eth2...

 And tsquz (3:rd col) in /proc/net/sofnet_stat indicates there are very 
 little activity from the RX softirq. It's soon time time up here.
 

						--ro
 
