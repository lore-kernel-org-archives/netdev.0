From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] RPS: Sparse connection optimizations - v2
Date: Mon, 07 May 2012 09:38:02 +0200
Message-ID: <1336376282.3752.2252.camel@edumazet-glaptop>
References: <1336035412-2161-1-git-send-email-dczhu@mips.com>
	 <CA+mtBx_J=fm3+k6_NzMH9KCdrYpZPwT2XBQe4r424eNDCKzazg@mail.gmail.com>
	 <4FA35A3D.8000205@mips.com>
	 <CA+mtBx-CErRU=3ewkAjVrGN3dGzjsTz8Q-E8J+Xa+529OVEvwA@mail.gmail.com>
	 <4FA77051.20804@mips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Deng-Cheng Zhu <dczhu@mips.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41149 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754194Ab2EGHiI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 03:38:08 -0400
Received: by eekc41 with SMTP id c41so1314898eek.19
        for <netdev@vger.kernel.org>; Mon, 07 May 2012 00:38:06 -0700 (PDT)
In-Reply-To: <4FA77051.20804@mips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-05-07 at 14:48 +0800, Deng-Cheng Zhu wrote:
> On 05/04/2012 11:31 PM, Tom Herbert wrote:
> >> I think the mechanisms of rps_dev_flow_table and cpu_flow (in this
> >> patch) are different: The former works along with rps_sock_flow_table
> >> whose CPU info is based on recvmsg by the application. But for the tests
> >> like what I did, there's no application involved.
> >>
> > While rps_sock_flow_table is currently only managed by recvmsg, it
> > still is the general mechanism that maps flows to CPUs for steering.
> > There should be nothing preventing you from populating and managing
> > entries in other ways.
> 
> Well, even using rps_sock_flow_table to map the sparse flows to CPUs,
> we still need a data structure to describe a single flow -- that's what
> struct cpu_flow is doing. Besides, rps_sock_flow_table, by its meaning,
> does not seem to make sense for our purpose. How about keeping the patch
> as is but renaming struct cpu_flow to struct rps_sparse_flow? It's like:
> 

sock_flow_table is about mapping a flow (by its rxhash) to cpu.

If you feel 'sock' is bad name, you can rename it.

You dont need adding new data structure and code in fast path.

Only the first packet of a new flow might be handled by 'the wrong cpu'.

If you add code in forward path to change flow_table for next packets,
added cost in fast path is null.
