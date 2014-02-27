From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Packet drops observed @ LINUX_MIB_TCPBACKLOGDROP
Date: Thu, 27 Feb 2014 09:54:09 -0800
Message-ID: <1393523649.26794.22.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJzFV35=wUOA+pQCkAwV2+oF79VAmbsRY08gZUiFz-Vtw-898w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:40918 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbaB0RyL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 12:54:11 -0500
Received: by mail-pd0-f176.google.com with SMTP id r10so2734900pdi.35
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 09:54:11 -0800 (PST)
In-Reply-To: <CAJzFV35=wUOA+pQCkAwV2+oF79VAmbsRY08gZUiFz-Vtw-898w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-02-26 at 19:00 -0700, Sharat Masetty wrote:
> Hi,
> 
> We are trying to achieve category 4 data rates on an ARM device. We
> see that with an incoming TCP stream(IP packets coming in and acks
> going out) lots of packets are getting dropped when the backlog queue
> is full. This is impacting overall data TCP throughput. I am trying to
> understand the full context of why this queue is getting full so
> often.
> 
> From my brief look at the code, it looks to me like the user space
> process is slow and busy in pulling the data from the socket buffer,
> therefore the TCP stack is using this backlog queue in the mean time.
> This queue is also charged against the main socket buffer allocation.
> 
> Can you please explain this backlog queue, and possibly confirm if my
> understanding this  matter is accurate?
> Also can you suggest any ideas on how to mitigate these drops?

You forgot to tell us things like :

1) Kernel version
2) Network driver in use.

Some drivers allocate huge buffers to store incoming frames.

Unfortunately we have to avoid OOM issues in the kernel, so such drivers
are likely to have some skb dropped by the backlog.
