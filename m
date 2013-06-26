From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC] about "net: orphan frags on receive" insanity
Date: Wed, 26 Jun 2013 12:56:42 +0300
Message-ID: <20130626095642.GA20982@redhat.com>
References: <1372235039.3301.126.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55943 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751831Ab3FZJz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 05:55:56 -0400
Content-Disposition: inline
In-Reply-To: <1372235039.3301.126.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 26, 2013 at 01:23:59AM -0700, Eric Dumazet wrote:
> Michael
> 
> Following commit added 400 bytes into __netif_receive_skb_core()
> 
> Could we revert it, and fix the problem into the callers instead ?
> 
> Thanks
> 
> 
> 
> commit 1080e512d44d4f67b8beb8edf25a1bbcb1066dc7
> Author: Michael S. Tsirkin <mst@redhat.com>
> Date:   Fri Jul 20 09:23:17 2012 +0000
> 
>     net: orphan frags on receive
>     
>     zero copy packets are normally sent to the outside
>     network, but bridging, tun etc might loop them
>     back to host networking stack. If this happens
>     destructors will never be called, so orphan
>     the frags immediately on receive.
>     
>     Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>

Please don't just revert it.

Packets can cross e.g. the bridge and end up on the external
interface, in which case that NIC guarantees that
they will get transmitted eventually, so it's safe
to transmit from guest memory, or they can end up
in the host stack where they can stay indefinitely,
in this case we need to orphan frags so guest networking
can keep going.

What do you suggest exactly?

Also, I'll have to look at the generated binary - when I
coded this up, compiler seemed to only put a
conditional branch on the fast path, this shouldn't
be all that expensive.

-- 
MST
