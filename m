From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Re: RFC: NAPI packet weighting patch
Date: Fri, 3 Jun 2005 00:15:50 +0200
Message-ID: <17055.34070.718986.664873@robur.slu.se>
References: <468F3FDA28AA87429AD807992E22D07E0450BFD0@orsmsx408>
	<20050602143126.7c302cfd@dxpl.pdx.osdl.net>
	<200506021651.49013.jdmason@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>,
        "Ronciak, John" <john.ronciak@intel.com>, hadi@cyberus.ca,
        "David S. Miller" <davem@davemloft.net>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jon Mason <jdmason@us.ibm.com>
In-Reply-To: <200506021651.49013.jdmason@us.ibm.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



 Differentiate the meaning of weight a bit.

 Let weight only limit the number of pkts we deliver per ->poll
 
 Have some other mechanism or threshold to control when interrupts are
 to be turned on.

 The first approximation for this could be to poll as long as we see 
 any pkt on the RX ring. As interrupt seems expensive on all platforms.

 Cheers.
						--ro


Jon Mason writes:
 > On Thursday 02 June 2005 04:31 pm, Stephen Hemminger wrote:
 > <...>
 > > For networking the problem is worse, the "right" choice depends on workload
 > > and relationship between components in the system. I can't see how you
 > > could ever expect a driver specific solution.
 > 
 > I think there is a way for a generic driver NAPI enhancement.  That is to 
 > modify the weight dependent on link speed.  
 > 
 > Here is the problem as I see it, NAPI enablement for slow media speeds causes 
 > unneeded strain on the system.  This is because of the "weight" of NAPI.  
 > Lets look at e1000 as an example.  Currently the NAPI weight is 64, 
 > regardless of link media speed.  This weight is probably fine for a gigabit 
 > link, but for 10/100 this is way to large.  Thus causing interrupts to be 
 > enabled/disabled after every poll/interrupt.  Lots of overhead, and not very 
 > smart.  Why not have the driver set the weight to 16/32 respectively for the 
 > weight (or better yet, have someone run numbers to find weight that are 
 > closer to what the adapter can actually use)?  While these numbers may not be 
 > optimal for every system, this is much better that the current system, and 
 > would only require 5 or so extra lines of code per NAPI enabled driver.
 > 
 > For those who want to have an optimal weight for their tuned system, let them 
 > use the /proc entry that is being proposed.
 > 
 > Thanks,
 > Jon
