From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: make TCP preemptible
Date: Thu, 28 Apr 2016 10:23:22 -0700
Message-ID: <20160428172320.GA83199@ast-mbp.thefacebook.com>
References: <1461821152-23200-1-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:35718 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753021AbcD1RX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 13:23:27 -0400
Received: by mail-pf0-f180.google.com with SMTP id 77so3655003pfv.2
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 10:23:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1461821152-23200-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 27, 2016 at 10:25:46PM -0700, Eric Dumazet wrote:
> Most of TCP stack assumed it was running from BH handler.
> 
> This is great for most things, as TCP behavior is very sensitive
> to scheduling artifacts.
> 
> However, the prequeue and backlog processing are problematic,
> as they need to be flushed with BH being blocked.
> 
> To cope with modern needs, TCP sockets have big sk_rcvbuf values,
> in the order of 16 MB.
> This means that backlog can hold thousands of packets, and things
> like TCP coalescing or collapsing on this amount of packets can
> lead to insane latency spikes, since BH are blocked for too long.
> 
> It is time to make UDP/TCP stacks preemptible.
> 
> Note that fast path still runs from BH handler.

this looks pretty awesome.
the change will make the backlog run in bh enabled, so that one
large flow reciever will not penalize the rest of the system, right?
but you're saying that prequeue is also expensive, but not touched
by this patchset? was it addressed by your eariler patch?
Or more work still tbd?
I'm just trying to understand more about tcp stack.
