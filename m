From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: e1000 autotuning doesn't get along with itself
Date: Fri, 17 Aug 2007 18:16:24 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F52032A40B8@orsmsx418.amr.corp.intel.com>
References: <46C4A888.9090006@hp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Rick Jones" <rick.jones2@hp.com>,
	"Linux Network Development list" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:65358 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbXHRBQg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:16:36 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46C4A888.9090006@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
Hi Rick, allow me to respond on my way out on a Friday... :-)

> hpcpc109:~/netperf2_trunk# src/netperf -t TCP_RR -H 192.168.2.105 -D
> 1.0 -l 15 TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0
> AF_INET to 192.168.2.105 (192.168.2.105) port 0 AF_INET : demo :
> first burst 0 
> Interim result: 10014.93 Trans/s over 1.00 seconds
> Interim result: 10015.79 Trans/s over 1.00 seconds
> Interim result: 10014.30 Trans/s over 1.00 seconds
> Interim result: 10016.29 Trans/s over 1.00 seconds
> Interim result: 10085.80 Trans/s over 1.00 seconds
> Interim result: 17526.61 Trans/s over 1.00 seconds
> Interim result: 20007.60 Trans/s over 1.00 seconds
> Interim result: 19626.46 Trans/s over 1.02 seconds
> Interim result: 10616.44 Trans/s over 1.85 seconds
> Interim result: 10014.88 Trans/s over 1.06 seconds
> Interim result: 10015.79 Trans/s over 1.00 seconds
> Interim result: 10014.80 Trans/s over 1.00 seconds
> Interim result: 10035.30 Trans/s over 1.00 seconds
> Interim result: 13974.69 Trans/s over 1.00 seconds
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
> 
> 16384  87380  1        1       15.00    12225.77
> 16384  87380

This is a pretty well expected behavior from this algorithm.  You're
basically getting a sine wave of the two ITR clocks.  At least your
average is 12,000 now.  Before this "dynamic tuning" your throughput
would have been 4,000-4,500 between two interfaces locked at 8000 ints a
sec.  You can test this by setting InterrruptThrottleRate=8000,8000,...
on both sides.

> On a slightly informed whim I tried disabling the interrupt thottle
> on both sides (modprobe e1000 InterruptThrottleRate=0,0,0,0,0,0,0,0)
> and re-ran: 
> 
> hpcpc109:~/netperf2_trunk# src/netperf -t TCP_RR -H 192.168.2.105 -D
> 1.0 -l 15TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0
> AF_INET to 192.168.2.105 (192.168.2.105) port 0 AF_INET : demo :
> first burst 0 
> Interim result: 18673.68 Trans/s over 1.00 seconds
> Interim result: 18685.01 Trans/s over 1.00 seconds
> Interim result: 18682.30 Trans/s over 1.00 seconds
> Interim result: 18681.05 Trans/s over 1.00 seconds
> Interim result: 18680.25 Trans/s over 1.00 seconds
> Interim result: 18742.44 Trans/s over 1.00 seconds
> Interim result: 18739.45 Trans/s over 1.00 seconds
> Interim result: 18723.52 Trans/s over 1.00 seconds
> Interim result: 18736.53 Trans/s over 1.00 seconds
> Interim result: 18737.61 Trans/s over 1.00 seconds
> Interim result: 18744.76 Trans/s over 1.00 seconds
> Interim result: 18728.54 Trans/s over 1.00 seconds
> Interim result: 18738.91 Trans/s over 1.00 seconds
> Interim result: 18735.53 Trans/s over 1.00 seconds
> Interim result: 18741.03 Trans/s over 1.00 seconds
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
> 
> 16384  87380  1        1       15.00    18717.94
> 16384  87380

and I'll bet that your systems max out in this test about 36000
interrupts per second on each side, giving you 1 interrupt per tx, and 1
interrupt per rx.
 
> and then just for grins I tried just disabling it on one side,
> leaving the other at defaults:
> 
> hpcpc109:~/netperf2_trunk# src/netperf -t TCP_RR -H 192.168.2.105 -D
> 1.0 -l 15TCP REQUEST/RESPONSE TEST from 0.0.0.0 (0.0.0.0) port 0
> AF_INET to 192.168.2.105 (192.168.2.105) port 0 AF_INET : demo :
> first burst 0 
> Interim result: 19980.84 Trans/s over 1.00 seconds
> Interim result: 19997.60 Trans/s over 1.00 seconds
> Interim result: 19995.60 Trans/s over 1.00 seconds
> Interim result: 20002.60 Trans/s over 1.00 seconds
> Interim result: 20011.58 Trans/s over 1.00 seconds
> Interim result: 19985.66 Trans/s over 1.00 seconds
> Interim result: 20002.60 Trans/s over 1.00 seconds
> Interim result: 20010.58 Trans/s over 1.00 seconds
> Interim result: 20012.60 Trans/s over 1.00 seconds
> Interim result: 19993.63 Trans/s over 1.00 seconds
> Interim result: 19979.63 Trans/s over 1.00 seconds
> Interim result: 19991.58 Trans/s over 1.00 seconds
> Interim result: 20011.60 Trans/s over 1.00 seconds
> Interim result: 19948.84 Trans/s over 1.00 seconds
> Local /Remote
> Socket Size   Request  Resp.   Elapsed  Trans.
> Send   Recv   Size     Size    Time     Rate
> bytes  Bytes  bytes    bytes   secs.    per sec
> 
> 16384  87380  1        1       15.00    19990.14
> 16384  87380

This is tied directly to the default of 20000 ints/second of the upper
limit of the default "dynamic" tuning.

> It looks like the e1000 interrupt throttle autotuning works very
> nicely when the other side isn't doing any, but if the other side is
> also trying to autotune it doesn't seem to stablize.  At least not
> during a netperf TCP_RR test. 

one of the side effects of the algorithm's fast response to bursty
traffic is that it ping pongs around quite a bit as your test transmits
and receives packets.  If you put the driver into
InterruptThrottleRate=1,1,1.... then the upper limit of interrupts goes
up to 70,000 ints/s, which may give you a still different result.
 
> Does anyone else see this?  To try to eliminate netperf demo mode I
> re-ran without it and got the same end results.

yes, we saw this and consider it normal.  Even one might call it an
improvement, since your latency is quite a bit lower (transactions is
quite a bit higher) than it used to be in this same test.

Should you need absolute lowest latency, InterruptThrottleRate=0 is the
way to go, but we hoped that the regular user using the default settings
would be pleased with a 10,000-20,000 transactions per second rate.  In
your case I would suggest InterruptThrottleRate=1 will still provide
better performance in this latency sensitive test while still allowing
for some interrupt mitigation if you all of a sudden decide to test bulk
traffic without reloading the driver.

Thanks for your numbers, its good to see things working expectedly.  If
you have suggestions for improvements please let me know,

  Jesse
