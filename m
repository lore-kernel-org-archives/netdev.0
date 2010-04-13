From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH v4] rfs: Receive Flow Steering
Date: Mon, 12 Apr 2010 17:12:05 -0700
Message-ID: <20100412171205.561a1aec@nehalam>
References: <alpine.DEB.1.00.1004121651460.31468@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, Ingo Molnar <mingo@elte.hu>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:44907 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754322Ab0DMAMR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 20:12:17 -0400
In-Reply-To: <alpine.DEB.1.00.1004121651460.31468@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 12 Apr 2010 17:03:39 -0700 (PDT)
Tom Herbert <therbert@google.com> wrote:

> The basic idea of RFS is that when an application calls recvmsg
> (or sendmsg) the application's running CPU is stored in a hash
> table that is indexed by the connection's rxhash which is stored in
> the socket structure.  The rxhash is passed in skb's received on
> the connection from netif_receive_skb.  For each received packet,
> the associated rxhash is used to look up the CPU in the hash table,
> if a valid CPU is set then the packet is steered to that CPU using
> the RPS mechanisms.

There are two sometimes conflicting models:

One model is to have the flow's be dispersed and let the scheduler
be smarter about running the applications on the right CPU's where
the packets arrive.

The other is to have the flows redirected to the CPU where the application
previously ran which is what RFS does.

For benchmarks and private fixed configuration systems it is tempting
to just nail everything down: i.e. use hard SMP affinity, for hardware, processes,
and flows.  But this is the wrong solution for general purpose systems with
varying workloads and requirements.  How well does RFS really work when
applications, processes, and sockets come and go or get migrated among
CPU's by the scheduler? My concern is this is overlapping scheduler
design and might be a step backwards.


-- 
