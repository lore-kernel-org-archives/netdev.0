From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: RFC: NAPI packet weighting patch
Date: Fri, 27 May 2005 10:21:11 +0200
Message-ID: <17046.55415.729135.240047@robur.slu.se>
References: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, john.ronciak@intel.com, ganesh.venkatesan@intel.com,
        jesse.brandeburg@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mitch Williams <mitch.a.williams@intel.com>
In-Reply-To: <Pine.CYG.4.58.0505261406210.2364@mawilli1-desk2.amr.corp.intel.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


 Hello!
 Some comments below.

Mitch Williams writes:

 > With the parameter set to 0 (the default), NAPI polling works exactly as
 > it does today:  each packet is worth one backlog work unit, and the
 > maximum number of received packets that will be processed in any given
 > softirq is controlled by the 'netdev_max_backlog' parameter.

 You should be able to accomplish on per-device basis with dev->weight 

 > By increasing the packet weight, we accomplish two things:  first, we
 > cause the individual NAPI RX loops in each driver to process fewer
 > packets.  This means that they will free up RX resources to the hardware
 > more often, which reduces the possibility of dropped packets.  

 I kind of interesting area and complex as weight setting should consider
 coalicing etc.as we try find an acceptable balance of interrupts, polls.
 and packtets per poll. Again to me this indicates that this should be done 
 on driver level.

 Do you have more details about the cases your were able to improve and how 
 your thingking was here. It's kind of unresearched area.

 > Second, it shortens the total time spent in the NAPI softirq, which can 
 > free the CPU to handle other tasks more often, thus reducing overall latency.

 At high packet load from several dev's we still only break the RX softirq 
 when exhausting the total budget or a jiffie. Generally the RX softirq is very 
 well-behaved due to this.

 Cheers.
					--ro
