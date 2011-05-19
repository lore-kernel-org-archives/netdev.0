From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: TCP funny-ness when over-driving a 1Gbps link.
Date: Thu, 19 May 2011 16:18:27 -0700
Message-ID: <20110519161827.2ba4b40e@nehalam>
References: <4DD59DF2.2070707@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:38167 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932723Ab1ESXSa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 19:18:30 -0400
In-Reply-To: <4DD59DF2.2070707@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 19 May 2011 15:47:14 -0700
Ben Greear <greearb@candelatech.com> wrote:

> I noticed something that struck me as a bit weird today,
> but perhaps it's normal.
> 
> I was using our application to create 3 TCP streams from one port to
> another (1Gbps, igb driver), running through a network emulator.
> Traffic is flowing bi-directional in each connection.
> 
> I am doing 24k byte writes per system call.  I tried 100ms, 10ms, and 1ms
> latency (one-way) in the emulator, but behaviour is similar in each case.
> The rest of this info was gathered with 1ms delay in the emulator.
> 
> If I ask all 3 connections to run 1Gbps, netstat shows 30+GB in the
> sending queues and 1+ second latency (user-space to user-space).  Aggregate
> throughput is around 700Mbps in each direction.
> 
> But, if I ask each of the connections to run at 300Mbps, latency averages
> 2ms and each connection runs right at 300Mbps (950Mbps or so on the wire).
> 
> It seems that when you over-drive the link, things back up and perform
> quite badly over-all.
> 
> This is a core-i7 3.2Ghz with 12GB RAM, Fedora 14, 2.6.38.6 kernel
> (with some hacks), 64-bit OS and user-space app.  Quick testing on 2.6.36.3
> showed similar results, so I don't think it's a regression.
> 
> I am curious if others see similar results?
> 
> Thanks,
> Ben
> 

If you overdrive, TCP expects your network emulator to have
a some but limited queueing (like a real router).

-- 
