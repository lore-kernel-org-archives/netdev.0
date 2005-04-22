From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 16:52:50 +0200
Message-ID: <17001.4034.250460.397016@robur.slu.se>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
	<1113855967.7436.39.camel@localhost.localdomain>
	<20050419055535.GA12211@sgi.com>
	<m1hdhzyrdz.fsf@muc.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Greg Banks <gnb@sgi.com>, Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <m1hdhzyrdz.fsf@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Andi Kleen writes:

 > We have seen similar behaviour. With NAPI some benchmarks run
 > a lot slower than on a driver on the same hardware/NIC without NAPI.
 > This can be even observed with simple tests like netperf single stream
 > between two boxes.
 > 
 > There seems to be also some problems with bidirectional traffic, although
 > I have not fully tracked them down to NAPI yet.
 > 
 > There is definitely some problem in NAPI land ...

  Well NAPI enforces very little policy it leaves a lot of freedom for 
  driver writers. Driver design i.e do work in interrupt or softirq, use 
  of interrupt mitigation etc etc. It's minimal approach to solve some very 
  severe problem we had with networking stack at a time were linux OS was not 
  an option at all. Knowing also a bit about the background as we experimented
  quite a bit about possible options. Alexey did the final kernel design 
  it got very well integrated into the kernel and softirq linux model.
  Dave understood directly and included the framework directly.

  So help us sort out the problems. And of course there are some differences
  or "issues" as we know every design has it's trade-off is bit Jamal said you 
  can't optimize in both ends. Or help us replace it with something thats 
  solves the same problems even better.
 
  Cheers.
						--ro
 
  BTW We talked with Intel folks about leaving irq disabled when reading
  ISR and some status bit were. This can save some PCI-accesses I don't
  if any experiments are done. MSI is also interesting in this aspect... 

  
