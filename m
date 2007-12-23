From: Ariane Keller <ariane.keller@tik.ee.ethz.ch>
Subject: Re: [PATCH 0/2] netem: trace enhancement
Date: Sun, 23 Dec 2007 20:54:24 +0100
Message-ID: <476EBCF0.3040507@ee.ethz.ch>
References: <20071120231131.oqn4s5eda84k4csw@email.ee.ethz.ch>	<474C2246.50205@ee.ethz.ch> <20071129134554.5c25a891@freepuppy.rosehill>	<474F3719.30101@trash.net> <47503971.9080509@ee.ethz.ch>	<4753B423.7030000@trash.net> <4753C874.80703@ee.ethz.ch>	<47543E65.4060303@trash.net> <47544B1F.1010902@candelatech.com> <20071204154535.4eu35nfe9wks8kgg@email.ee.ethz.ch> <47559119.6070803@candelatech.com> <47559455.1080009@ee.ethz.ch> <47559763.9050408@candelatech.com> <4755C984.70906@ee.ethz.ch> <4755D2EB.4000807@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ariane Keller <ariane.keller@tik.ee.ethz.ch>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Rainer Baumann <baumann@tik.ee.ethz.ch>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.ee.ethz.ch ([129.132.2.219]:39051 "EHLO smtp.ee.ethz.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751360AbXLWTyf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Dec 2007 14:54:35 -0500
In-Reply-To: <4755D2EB.4000807@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have added the possibility to configure the number
of buffers used to store the trace data for packet delays.
The complete command to start netem with a trace file is:
tc qdisc add dev eth1 root netem trace path/to/trace/file.bin buf 3 
loops 1 0
with buf: the number of buffers to be used
loops: how many times to loop through the tracefile
the last argument is optional and specifies whether the default is to 
drop packets or 0-delay them.

The patches are available at:
http://www.tcn.hypert.net/tcn_kernel_2_6_23_confbuf
http://www.tcn.hypert.net/tcn_iproute2_2_6_23_confbuf

I'm looking forward for your comments!
Thanks!
Ariane


Ben Greear wrote:
> Ariane Keller wrote:
> 
>> Yes, for short-term starvation it helps certainly.
>> But I'm still not convinced that it is really necessary to add more 
>> buffers, because I'm not sure whether the bottleneck is really the 
>> loading of data from user space to kernel space.
>> Some basic tests have shown that the kernel starts loosing packets at 
>> approximately the same packet rate regardless whether we use netem, or 
>> netem with the trace extension.
>> But if you have contrary experience I'm happy to add a parameter which 
>> defines the number of buffers.
> 
> I have no numbers, so if you think it works, then that is fine with me.
> 
> If you actually run out of the trace buffers, do you just continue to
> run with the last settings?  If so, that would keep up throughput
> even if you are out of trace buffers...
> 
> What rates do you see, btw?  (pps, bps).
> 
> Thanks,
> Ben
> 

-- 
Ariane Keller
Communication Systems Research Group, ETH Zurich
Web: http://www.csg.ethz.ch/people/arkeller
Office: ETZ G 60.1, Gloriastrasse 35, 8092 Zurich
