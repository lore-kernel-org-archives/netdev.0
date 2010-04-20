From: Ben Greear <greearb@candelatech.com>
Subject: Re: PROBLEM: Linux kernel 2.6.31 IPv4 TCP fails to open huge amount
 	of outgoing connections (unable to bind ... )
Date: Tue, 20 Apr 2010 16:30:55 -0700
Message-ID: <4BCE392F.60104@candelatech.com>
References: <g2z46c8cb3e1004201517i5641a75cze2ec5bd33e81fb0f@mail.gmail.com>	 <4BCE33B9.8050101@candelatech.com> <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Gaspar Chilingarov <gasparch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34973 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753425Ab0DTXa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 19:30:57 -0400
In-Reply-To: <u2t46c8cb3e1004201620tf9fce087ibae421759f9e1e84@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/20/2010 04:20 PM, Gaspar Chilingarov wrote:
> Opening that amount of incoming connections in not a problem at all.
>
> I'm speaking of outgoing connections.
>
> What kind of hack do you have on your kernel?

send-to-self logic and similar..but nothing that should be
better at doing lots of sockets than the default kernel.

I have 40,000 out-going connections to myself..basically I'm
acting as both client and server.  So, I'd expect you to be
able to do around 80,000 connections to some external system on
similar hardware and efficient client software.  At least with
my software, I'd need more RAM to scale much beyond that, but I'm
trying to generate traffic on these sockets (which requires user-space
buffers per socket in my implementation), and I have a decent bit
of overhead gathering stats and such.  A simpler application with
less overhead should do more sockets.

Be sure to use lots of processes so you don't end up with
a poll loop with 80,000 fd entries.  I found that 10k sockets
per process was a good upper limit..but it's not a hard
upper limit.

And be sure to do the bind logic correctly as Eric pointed out in an
earlier email.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
