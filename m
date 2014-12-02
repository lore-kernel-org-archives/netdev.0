From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH] netfilter: conntrack: cache route for forwarded
 connections
Date: Mon, 01 Dec 2014 17:36:43 -0800
Message-ID: <1417484203.4442.19.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1417480114-3002-1-git-send-email-fw@strlen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, brouer@redhat.com,
	netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1417480114-3002-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2014-12-02 at 01:28 +0100, Florian Westphal wrote:
> ... to avoid per-packet FIB lookup if possible.
> 
> The cached dst is re-used provided the input interface
> is the same as that of the previous packet in the same direction.
> 
> If not, the cached dst is invalidated.
> 
> This should speed up forwarding when conntrack is already in use
> anyway, especially when using reverse path filtering -- active RPF
> enforces two FIB lookups for each packet.
> 
> Before the routing cache removal this didn't matter since RPF
> was performed only when route cache didn't yield a result; but without
> route cache it comes at high price.
> 
> Signed-off-by: Florian Westphal <fw@strlen.de>
> ---

Seems a good idea (but you might need some IPv6 care, as ( dst =
dst_check(dst, 0); ) seems to handle IPv4 only)

Another idea would be to re-use TCP ehash so that regular IP early demux
can be used, with a single lookup for both local and forwarded sessions.

(That would probably require a bit more memory, as you would need to
insert into TCP ehash some kind of 'tiny sockets' )

