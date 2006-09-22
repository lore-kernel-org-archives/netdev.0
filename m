From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 2.6.16.19 2/2] LARTC: trace control for netem:
 kernelspace
Date: Fri, 22 Sep 2006 10:20:56 -0700
Message-ID: <20060922102056.0069f944@localhost.localdomain>
References: <45137F71.2000404@tik.ee.ethz.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@VGER.KERNEL.ORG, netem@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
To: Rainer Baumann <baumann@tik.ee.ethz.ch>
In-Reply-To: <45137F71.2000404@tik.ee.ethz.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 22 Sep 2006 08:15:13 +0200
Rainer Baumann <baumann@tik.ee.ethz.ch> wrote:

> Trace Control for Netem: Emulate network properties such as long range dependency and self-similarity of cross-traffic.
> 
> kernel space:
> The delay, drop, duplication and corruption values are readout in user space and sent to kernel space via configfs. The userspace process will "hang on write" until the kernel needs new data.
> 
> In order to have always packet action values ready to apply, there are two buffers that hold these values. Packet action values can be read from one buffer and the other buffer can be refilled with new values simultaneously. The synchronization of "need more delay values" and "return from write" is done with the use of wait queues.
> 
> Having applied the delay value to a packet, the packet gets processed by the original netem functions.
> 
> Signed-off-by: Rainer Baumann <baumann@tik.ee.ethz.ch>
> 
> ---
> 
> Patch for linux kernel 2.6.16.19: http://tcn.hypert.net/tcnKernel_procfs.patch

I like the concept of the trace based delay stuff, it is just that the implementation
needs more work.

Style:
	* whitespace around operators, keywords etc
	* use /* for comments not //
	* indentation
	scripts/Lindent may help
	* accidental blank line changes introduced in patch as well

	* You don't really change Makefile
Code:
	* now netem depends on CONFIG_PROC_FS

	* why not use a miscdevice (/dev/netem_trace?) instead of /proc
	  
	* still has signal flow control to process. This is an awkward way
	  to do flow control and I don't think it is safe.
	
	* hard coding MAX_FLOWS leads to scaling problems. Not all users will
	  want to waste the memory, and what if there are more flows. Can't you
	  figure out a way to allocate and scale flow buffers.


	



-- 
Stephen Hemminger <shemminger@osdl.org>
