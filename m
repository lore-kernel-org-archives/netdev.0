From: Ben Greear <greearb@candelatech.com>
Subject: Re: TCP funny-ness when over-driving a 1Gbps link.
Date: Thu, 19 May 2011 16:42:52 -0700
Message-ID: <4DD5AAFC.8070509@candelatech.com>
References: <4DD59DF2.2070707@candelatech.com> <20110519161827.2ba4b40e@nehalam> <4DD5A5CD.7040303@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:59161 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933391Ab1ESXmx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 19:42:53 -0400
In-Reply-To: <4DD5A5CD.7040303@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/19/2011 04:20 PM, Ben Greear wrote:
> On 05/19/2011 04:18 PM, Stephen Hemminger wrote:

>> If you overdrive, TCP expects your network emulator to have
>> a some but limited queueing (like a real router).
>
> The emulator is fine, it's not being over-driven (and has limited
> queueing if it was
> being over-driven). The queues that are backing up are in the tcp
> sockets on the
> sending machine.
>
> But, just to make sure, I'll re-run the test with a looped back cable...

Well, with looped back cable, it isn't so bad.  I still see a small drop
in aggregate throughput (around 900Mbps instead of 950Mbps), and
latency goes above 600ms, but it still performs better than when
going through the emulator.

At 950+Mbps, the emulator is going to impart 1-2 ms of latency
even when configured for wide-open.

If I use a bridge in place of the emulator, it seems to settle on
around 450Mbps in one direction and 945Mbps in the other (on the wire),
with round-trip latencies often over 5 seconds (user-space to user-space),
and a consistent large chunk of data in the socket send buffers:

[root@i7-965-1 igb]# netstat -an|grep tcp|grep 8.1.1
tcp        0      0 8.1.1.1:33038               0.0.0.0:*                   LISTEN
tcp        0      0 8.1.1.1:33040               0.0.0.0:*                   LISTEN
tcp        0      0 8.1.1.1:33042               0.0.0.0:*                   LISTEN
tcp        0 9328612 8.1.1.2:33039               8.1.1.1:33040               ESTABLISHED
tcp        0 17083176 8.1.1.1:33038               8.1.1.2:33037               ESTABLISHED
tcp        0 9437340 8.1.1.2:33037               8.1.1.1:33038               ESTABLISHED
tcp        0 17024620 8.1.1.1:33040               8.1.1.2:33039               ESTABLISHED
tcp        0 19557040 8.1.1.1:33042               8.1.1.2:33041               ESTABLISHED
tcp        0 9416600 8.1.1.2:33041               8.1.1.1:33042               ESTABLISHED

Thanks,
Ben


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

