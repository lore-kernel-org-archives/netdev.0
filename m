From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4] inet: prevent leakage of uninitialized memory to user in recv syscalls
Date: Mon, 18 Nov 2013 23:14:17 +0100
Message-ID: <20131118221417.GM16541@order.stressinduktion.org>
References: <1384648584.8604.39.camel@edumazet-glaptop2.roam.corp.google.com> <20131117192240.GI16541@order.stressinduktion.org> <20131118032045.GJ16541@order.stressinduktion.org> <20131118.151430.75221704090778394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, mpb.mail@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:51155 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751350Ab3KRWOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Nov 2013 17:14:18 -0500
Content-Disposition: inline
In-Reply-To: <20131118.151430.75221704090778394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 18, 2013 at 08:13:50AM -0800, Eric Dumazet wrote:
> This definitely looks much better, as this will remove lot of crap,
> thanks !
> 
> unix_dgram_recvmsg() and unix_stream_recvmsg() for example clear
> msg_namelen

Most recvfrom calls are fine, but there is appletalk, tun and even macvtap
and a lot other recvmsg calls I still have to check.

On Mon, Nov 18, 2013 at 03:14:30PM -0500, David Miller wrote:
> This looks a lot better than your previous attempts, nice work.
> 
> Applied and queued up for -stable.
> 
> The handling of msg_name/msg_namelen in the ->recvmsg proto op is decidedly
> non-trivial.  Can I suggest that we at least add some documentation about
> this semantic above "(*recvmsg)" in the definition of proto_ops in
> include/linux/net.h?

Thanks!

I even want to come up with a better scheme for that. I do think we
can pass msg_namelen == 0 initially and let the recvmsg handlers update
it. So we have a safe fallback. The possible uninitialized memory leaks
can be pretty big, so I would like to see new recvmsg callers not return
anything if they don't care about msg_namelen. This should get noticed
during testing.

I'll add documentation in future patches.
