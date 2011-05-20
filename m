From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP funny-ness when over-driving a 1Gbps link.
Date: Thu, 19 May 2011 17:05:40 -0700
Message-ID: <1305849940.8149.1122.camel@tardy>
References: <4DD59DF2.2070707@candelatech.com>
	 <20110519161827.2ba4b40e@nehalam> <4DD5A5CD.7040303@candelatech.com>
	 <4DD5AAFC.8070509@candelatech.com>
Reply-To: rick.jones2@hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:22838 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752572Ab1ETAFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 20:05:42 -0400
In-Reply-To: <4DD5AAFC.8070509@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2011-05-19 at 16:42 -0700, Ben Greear wrote:
> On 05/19/2011 04:20 PM, Ben Greear wrote:
> > On 05/19/2011 04:18 PM, Stephen Hemminger wrote:
> 
> >> If you overdrive, TCP expects your network emulator to have
> >> a some but limited queueing (like a real router).
> >
> > The emulator is fine, it's not being over-driven (and has limited
> > queueing if it was
> > being over-driven). The queues that are backing up are in the tcp
> > sockets on the
> > sending machine.
> >
> > But, just to make sure, I'll re-run the test with a looped back cable...
> 
> Well, with looped back cable, it isn't so bad.  I still see a small drop
> in aggregate throughput (around 900Mbps instead of 950Mbps), and
> latency goes above 600ms, but it still performs better than when
> going through the emulator.
> 
> At 950+Mbps, the emulator is going to impart 1-2 ms of latency
> even when configured for wide-open.
> 
> If I use a bridge in place of the emulator, it seems to settle on
> around 450Mbps in one direction and 945Mbps in the other (on the wire),
> with round-trip latencies often over 5 seconds (user-space to user-space),
> and a consistent large chunk of data in the socket send buffers:
> 
> [root@i7-965-1 igb]# netstat -an|grep tcp|grep 8.1.1
> tcp        0      0 8.1.1.1:33038               0.0.0.0:*                   LISTEN
> tcp        0      0 8.1.1.1:33040               0.0.0.0:*                   LISTEN
> tcp        0      0 8.1.1.1:33042               0.0.0.0:*                   LISTEN
> tcp        0 9328612 8.1.1.2:33039               8.1.1.1:33040               ESTABLISHED
> tcp        0 17083176 8.1.1.1:33038               8.1.1.2:33037               ESTABLISHED
> tcp        0 9437340 8.1.1.2:33037               8.1.1.1:33038               ESTABLISHED
> tcp        0 17024620 8.1.1.1:33040               8.1.1.2:33039               ESTABLISHED
> tcp        0 19557040 8.1.1.1:33042               8.1.1.2:33041               ESTABLISHED
> tcp        0 9416600 8.1.1.2:33041               8.1.1.1:33042               ESTABLISHED

I take it your system has higher values for the tcp_wmem value:

net.ipv4.tcp_wmem = 4096 16384 4194304

and whatever is creating the TCP connections is not making explicit
setsockopt() calls to set SO_*BUF.

rick jones

