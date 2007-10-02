From: Rick Jones <rick.jones2@hp.com>
Subject: Re: tcp bw in 2.6
Date: Tue, 02 Oct 2007 10:14:11 -0700
Message-ID: <47027C63.803@hp.com>
References: <20070929142517.EC6AB5FB21@work.bitmover.com>	<alpine.LFD.0.999.0709290914410.3579@woody.linux-foundation.org>	<20070929172639.GB7037@bitmover.com>	<alpine.LFD.0.999.0709291050200.3579@woody.linux-foundation.org>	<20071002005917.GB5480@bitmover.com>	<alpine.LFD.0.999.0710011858400.3579@woody.linux-foundation.org> <20071002022059.GE7037@bitmover.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	davem@davemloft.net, wscott@bitmover.com, netdev@vger.kernel.org
To: Larry McVoy <lm@bitmover.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:59172 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511AbXJBROO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 13:14:14 -0400
In-Reply-To: <20071002022059.GE7037@bitmover.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Larry McVoy wrote:
> A short summary is "can someone please post a test program that sources
> and sinks data at the wire speed?"  because apparently I'm too old and
> clueless to write such a thing.

http://www.netperf.org/svn/netperf2/trunk/

:)

WRT the different speeds in each direction talking with HP-UX, perhaps there is 
an interaction between the Linux TCP stack (TSO perhaps) and HP-UX's ACK 
avoidance heuristics. If that is the case, tweaking tcp_deferred_ack_max with 
ndd on the HP-UX system might yield different results.

I don't recall if the igelan (broadcom) driver in HP-UX attempts to auto-tune 
the interrupt throttling.  I do believe the iether (intel) driver in HP-UX does. 
  That can be altered via lanadmin -X mumble... commands.

Later (although later than a 2.6.18 kernel IIRC) e1000 drivers do try to 
auto-tune the interrupt throttling and one can see oscilations when an e1000 
driver is talking to an e1000 driver.  I think that can only be changed via the 
InterruptThrotleRate e1000 module parameter in that era of kernel - not sure if 
the Intel folks have that available via ethtool on contemporary kernels now or not.

WRT the small program making a setsockopt(SO_*BUF) call going slower than the 
rsh, does rsh make the setsockopt() call, or does it bend itself to the will of 
the linux stack's autotuning?  What happens if your small program does not make 
  setsockopt(SO_*BUF) calls?

Other misc observations of variable value:

*) depending on the quantity of CPU around, and the type of test one is running, 
results can be better/worse depending on the CPU to which you bind the 
application.  Latency tends to be best when running on the same core as takes 
interrupts from the NIC, bulk transfer can be better when running on a different 
core, although generally better when a different core on the same chip.  These 
days the throughput stuff is more easily seen on 10G, but the netperf service 
demand changes are still visible on 1G.

*) agreement with the observation that the small recv calls suggest that the 
application is staying-up with the network.  I doubt that SO_&BUF settings would 
change that, but perhaps setting watermarks might (wild ass guess).  The 
watermarks will do nothing on HP-UX though (IIRC).

rick jones
