From: Florian Westphal <fw@strlen.de>
Subject: Re: GRO issue with kernel 3.4.94 (icmp fragmentation needed)
Date: Fri, 27 Jun 2014 11:05:25 +0200
Message-ID: <20140627090525.GA30075@breakpoint.cc>
References: <000201cf9198$3cfa3200$b6ee9600$@whitecode.co.kr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jungwon park <jwpark2@whitecode.co.kr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33671 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751598AbaF0JF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 05:05:29 -0400
Content-Disposition: inline
In-Reply-To: <000201cf9198$3cfa3200$b6ee9600$@whitecode.co.kr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jungwon park <jwpark2@whitecode.co.kr> wrote:
> When using the linux router is turned on GRO, router send the 'fragmentation
> needed' packets to the sender.

Indeed 8-(

> When I turned off GRO, the router operate normally, and there is no problem.
> and with 3.4.91 kernel, the router has no problem.
> 
> I doubt 'ipv4: ip_forward: fix inverted local_df test' patch.
> (http://patchwork.ozlabs.org/patch/345509/)
> When I revert this patch, the router has no problem.

Can you please cherry-pick following patch on top of vanilla 3.4.92?
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=21d1196a35f5686c4323e42a62fdb4b23b0ab4a3

commit 21d1196a35f5686c4323e42a62fdb4b23b0ab4a3
Author: Eric Dumazet <edumazet@google.com>
ipv4: set transport header earlier

I think that should fix this bug, it should apply cleanly on top of
3.4.y tree.

[ patch is in 3.11, also backported to 3.10.y tree ]

The problem is that, when dealing with GRO packets, we try to determine
the size of the individual packets.  To do this, we rely on the
transport header.

Unfortunately the transport header is not set for the forward path in 3.4,
so we look at the network header instead.
