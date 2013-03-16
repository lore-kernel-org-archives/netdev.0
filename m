From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [RFC PATCH net-next (V2, RESENT)] ipv6: Queue fragments per interface for multicast/link-local addresses.
Date: Sat, 16 Mar 2013 08:47:45 +0100
Message-ID: <20130316074745.GC24041@order.stressinduktion.org>
References: <511F1E03.9010205@linux-ipv6.org> <511FB776.8000901@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev <netdev@vger.kernel.org>, netfilter-devel@vger.kernel.org
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <511FB776.8000901@linux-ipv6.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 17, 2013 at 01:44:38AM +0900, YOSHIFUJI Hideaki wrote:
> We should queue fragments for the same link-local address on
> different interfaces (e.g. fe80::1%eth0 and fe80::1%eth1) to the
> different queue, because of nature of addressing architecture.
> 
> Similarly, we should queue fragments for multicast on different
> interface to the different queue.  This is okay because
> application joins group on speicific interface, and multicast
> traffic is expected only on that interface.
> 
> CC: Ben Greear <greearb@candelatech.com>
> CC: Vlad Yasevich <vyasevic@redhat.com>
> CC: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

I just found this patch while cleaning up my tree. I don't know its state
(netdev patchworks says RFC and netfilter patchworks still lists it as
new). However, I also do think that the per interface matching would be
the right thing to do for multicast|linklocal fragments. Perhaps this patch
should be resend?

Yoshifuji, do you think we should also implement RFC 3168 5.3 ECN
fragmentation protection in reassembly.c? I think it should be
straightforward because it is already implemented for ipv4 and the
relevant bits just need to be moved to inet_fragment.c and become a bit
more generalized.

Thanks,

  Hannes

