From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v3] ip: fix truesize mismatch in ip fragmentation
Date: Tue, 21 Sep 2010 21:21:54 +0200
Message-ID: <20100921192154.GA2115@del.dom.local>
References: <20100920174443.GA5515@elliptictech.com>
 <1285006844.2323.17.camel@edumazet-laptop>
 <20100920195256.GA14330@elliptictech.com>
 <1285013853.2323.148.camel@edumazet-laptop>
 <1285018272.2323.243.camel@edumazet-laptop>
 <20100921140501.GA21572@elliptictech.com>
 <1285078613.2617.503.camel@edumazet-laptop>
 <1285084705.2617.636.camel@edumazet-laptop>
 <20100921175014.GA2066@del.dom.local>
 <1285094865.2452.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Bowler <nbowler@elliptictech.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33719 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755333Ab0IUTWB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 15:22:01 -0400
Content-Disposition: inline
In-Reply-To: <1285094865.2452.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 21, 2010 at 08:47:45PM +0200, Eric Dumazet wrote:
> 
> > Looks better and better to me, except, checkpatch complains about the
> > (existing) indentation fault here (and later), but I guess you've seen
> > that?
> > 
> 
> Indeed, there is checkpatch somewhere ;)
> 
> Thanks !
> 
> [PATCH v4] ip: fix truesize mismatch in ip fragmentation
> 
> Special care should be taken when slow path is hit in ip_fragment() :
> 
> When walking through frags, we transfert truesize ownership from skb to
> frags. Then if we hit a slow_path condition, we must undo this or risk
> uncharging frags->truesize twice, and in the end, having negative socket
> sk_wmem_alloc counter, or even freeing socket sooner than expected.
> 
> Many thanks to Nick Bowler, who provided a very clean bug report and
> test program.
> 
> Thanks to Jarek for reviewing my first patch and providing a V2
> 
> While Nick bisection pointed to commit 2b85a34e911 (net: No more
> expensive sock_hold()/sock_put() on each tx), underlying bug is older
> (2.6.12-rc5)
> 
> A side effect is to extend work done in commit b2722b1c3a893e
> (ip_fragment: also adjust skb->truesize for packets not owned by a
> socket) to ipv6 as well.
> 
> Reported-and-bisected-by: Nick Bowler <nbowler@elliptictech.com>
> Tested-by: Nick Bowler <nbowler@elliptictech.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jarek Poplawski <jarkao2@gmail.com>
> CC: Patrick McHardy <kaber@trash.net>

Looks perfect to me.

Jarek P.
