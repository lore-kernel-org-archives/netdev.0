From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: V2.4 policy router operates faster/better than V2.6
Date: Wed, 5 Jan 2005 14:18:19 +0100
Message-ID: <16859.59675.522262.418329@robur.slu.se>
References: <200501031455.26980.jeremy.guthrie@berbee.com>
	<20050103145115.4bdb2cd6@dxpl.pdx.osdl.net>
	<200501031656.57041.jeremy.guthrie@berbee.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: jeremy.guthrie@berbee.com
In-Reply-To: <200501031656.57041.jeremy.guthrie@berbee.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Jeremy M. Guthrie writes:
 > How would I check?  It should be in the hundreds of thousands.

 Good question  Stephen,..

 Yes it seems like this pretty hefty load. Forwarding rate of 92k kpps 
 and a drop rate of 10 kpps and dst hash mostly at 50-60 kentries if 
 I read the stats correctly.
 
 And 2.4 were able handle this but not 2.6.10?  
 
 Assuming things are uses and setup identically. 2.6 uses RCU for route hash 
 locking. Any dst cache overslow messages seen?

 A couple of lines of rtstat would be very interesing from this box.

 Also check that the CPU shares the RX packet load. CPU0 affinty to eth0 
 and CPU1 to eth1 seems to be best. It gives cache bouncing at "TX" and
 slab jobs but we have accept that for now. 

 13:37:25     CPU   %user   %nice %system %iowait    %irq   %soft   %idle    
> intr/s
> 13:38:24     all    0.14    0.00    0.12    0.12    2.02   42.89   54.71  
> 25900.70
> 13:38:24       0    0.03    0.00    0.05    0.22    0.00   16.67   83.03   
> 2246.10
> 13:38:24       1    0.25    0.00    0.20    0.03    4.02   69.12   26.40  
> 23654.55

This looks weird to me... we cannot have CPU left? Due to the imbalance?

Check /proc/net/softnet_stat,

Haven't used mpstat. %soft is that *all* softirq's or only softirq's deferred 
to ksoftird only?

						--ro
