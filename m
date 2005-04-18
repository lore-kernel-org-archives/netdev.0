From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: NAPI, e100, and system performance problem
Date: Mon, 18 Apr 2005 21:34:49 +0200
Message-ID: <16996.3033.886236.664281@robur.slu.se>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
	<Pine.LNX.4.61.0504180943290.15052@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Arthur Kepner <akepner@sgi.com>
In-Reply-To: <Pine.LNX.4.61.0504180943290.15052@linux.site>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Arthur Kepner writes:
 > 
 > On Sun, 17 Apr 2005, Brandeburg, Jesse wrote:
 > 
 > > ......
 > > _conclusion_
 > > 
 > > Is there any way we can configure how soon or often to be polled
 > > (called)? For 100Mb speeds at worst we can get about one 64 byte packet
 > > every 9us (if I did my math right) and since the processors don't take
 > > that long to schedule NAPI, process a packet and handle an interrupt, we
 > > just overload the system with interrupts going into and out of napi
 > > mode.  In this case I only have one adapter getting scheduled.
 > > 
 > 
 > I'll just chime in to say that I've seen similar behavior,
 > (but with a very different system.)
 > 
 > The problem with NAPI is (quoting a co-worker) that it
 > relies on an "accident of timing".
 > 
 > If the CPU speed, time to complete a PIO, and the inter-
 > packet arrival time are "just so", then a system (or at
 > least one of its CPUs) can be kept very busy even when
 > it's not receiving data from the network at a particularly
 > high rate.
 > 
 > The simple feedback mechanism used by NAPI is good at
 > balancing latency and throughput, but it doesn't have
 > any way of recognizing when system resources are being
 > poorly utilized. It would be nice if interrupt coalesence
 > could be used by NAPI (or maybe by NAPI_2 ?) in this sort
 > of situation.

 Well there is nothing that prohibits interrupt coalescing use with 
 NAPI as is.  Matter of there are many drivers using this i.e e1000
 and tulip. You trade latency for more packets per interrupt.

 Cheers.
					--ro
