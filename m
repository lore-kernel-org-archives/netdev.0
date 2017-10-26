From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net v2] xfrm: Clear sk_dst_cache when applying per-socket
 policy.
Date: Thu, 26 Oct 2017 12:54:14 +0200
Message-ID: <20171026105413.GT3323@secunet.com>
References: <20170815222510.21711-1-misterikkit@google.com>
 <20171025165227.6469-1-misterikkit@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <jkbs@redhat.com>, <davem@davemloft.net>,
        <lorenzo@google.com>, <eric.dumazet@gmail.com>
To: Jonathan Basseri <misterikkit@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:52364 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932141AbdJZKyQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 06:54:16 -0400
Content-Disposition: inline
In-Reply-To: <20171025165227.6469-1-misterikkit@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 25, 2017 at 09:52:27AM -0700, Jonathan Basseri wrote:
> If a socket has a valid dst cache, then xfrm_lookup_route will get
> skipped. However, the cache is not invalidated when applying policy to a
> socket (i.e. IPV6_XFRM_POLICY). The result is that new policies are
> sometimes ignored on those sockets. (Note: This was broken for IPv4 and
> IPv6 at different times.)
> 
> This can be demonstrated like so,
> 1. Create UDP socket.
> 2. connect() the socket.
> 3. Apply an outbound XFRM policy to the socket. (setsockopt)
> 4. send() data on the socket.
> 
> Packets will continue to be sent in the clear instead of matching an
> xfrm or returning a no-match error (EAGAIN). This affects calls to
> send() and not sendto().
> 
> Invalidating the sk_dst_cache is necessary to correctly apply xfrm
> policies. Since we do this in xfrm_user_policy(), the sk_lock was
> already acquired in either do_ip_setsockopt() or do_ipv6_setsockopt(),
> and we may call __sk_dst_reset().
> 
> Performance impact should be negligible, since this code is only called
> when changing xfrm policy, and only affects the socket in question.
> 
> Fixes: 00bc0ef5880d ("ipv6: Skip XFRM lookup if dst_entry in socket cache is valid")
> Tested: https://android-review.googlesource.com/517555
> Tested: https://android-review.googlesource.com/418659
> Signed-off-by: Jonathan Basseri <misterikkit@google.com>

Applied, thanks for your work Jonathan!
