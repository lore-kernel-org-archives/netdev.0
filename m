From: Jon Mason <jdmason@us.ibm.com>
Subject: Re: RFC: NAPI packet weighting patch
Date: Thu, 2 Jun 2005 16:51:48 -0500
Message-ID: <200506021651.49013.jdmason@us.ibm.com>
References: <468F3FDA28AA87429AD807992E22D07E0450BFD0@orsmsx408> <20050602143126.7c302cfd@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Ronciak, John" <john.ronciak@intel.com>, hadi@cyberus.ca,
        "David S. Miller" <davem@davemloft.net>,
        "Williams, Mitch A" <mitch.a.williams@intel.com>, netdev@oss.sgi.com,
        Robert.Olsson@data.slu.se,
        "Venkatesan, Ganesh" <ganesh.venkatesan@intel.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20050602143126.7c302cfd@dxpl.pdx.osdl.net>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thursday 02 June 2005 04:31 pm, Stephen Hemminger wrote:
<...>
> For networking the problem is worse, the "right" choice depends on workload
> and relationship between components in the system. I can't see how you
> could ever expect a driver specific solution.

I think there is a way for a generic driver NAPI enhancement.  That is to 
modify the weight dependent on link speed.  

Here is the problem as I see it, NAPI enablement for slow media speeds causes 
unneeded strain on the system.  This is because of the "weight" of NAPI.  
Lets look at e1000 as an example.  Currently the NAPI weight is 64, 
regardless of link media speed.  This weight is probably fine for a gigabit 
link, but for 10/100 this is way to large.  Thus causing interrupts to be 
enabled/disabled after every poll/interrupt.  Lots of overhead, and not very 
smart.  Why not have the driver set the weight to 16/32 respectively for the 
weight (or better yet, have someone run numbers to find weight that are 
closer to what the adapter can actually use)?  While these numbers may not be 
optimal for every system, this is much better that the current system, and 
would only require 5 or so extra lines of code per NAPI enabled driver.

For those who want to have an optimal weight for their tuned system, let them 
use the /proc entry that is being proposed.

Thanks,
Jon
