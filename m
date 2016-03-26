From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC net-next 2/2] udp: No longer use SLAB_DESTROY_BY_RCU
Date: Fri, 25 Mar 2016 18:55:58 -0700
Message-ID: <20160326015556.GA84340@ast-mbp.thefacebook.com>
References: <1458944964-12890-1-git-send-email-edumazet@google.com>
 <1458944964-12890-3-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:36480 "EHLO
	mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752594AbcCZB4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 21:56:03 -0400
Received: by mail-pf0-f171.google.com with SMTP id u190so93782395pfb.3
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 18:56:02 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1458944964-12890-3-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 03:29:24PM -0700, Eric Dumazet wrote:
> Tom Herbert would like to avoid touching UDP socket refcnt for encapsulated
> traffic. For this to happen, we need to use normal RCU rules, with a grace
> period before freeing a socket. UDP sockets are not short lived in the
> high usage case, so the added cost of call_rcu() should not be a concern.
> 
> This actually removes a lot of complexity in UDP stack
> 
> Multicast receives no longer need to hold a bucket lock.
> 
> Note that ip early demux still needs to take a reference on the socket.
> 
> Same remark for functions used by xt_socket and xt_PROXY netfilter modules,
> but this might be changed later.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <tom@herbertland.com>
> ---
>  include/linux/udp.h |   8 +-
>  include/net/sock.h  |  12 +--
>  include/net/udp.h   |   2 +-
>  net/ipv4/udp.c      | 290 +++++++++++++++-------------------------------------
>  net/ipv4/udp_diag.c |  18 ++--
>  net/ipv6/udp.c      | 194 +++++++++++------------------------
>  6 files changed, 162 insertions(+), 362 deletions(-)

great stuff!
