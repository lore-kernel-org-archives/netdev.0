From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [net-next PATCH v3 7/8] epoll: Add busy poll support to epoll
 with socket fds.
Date: Fri, 24 Mar 2017 20:33:38 -0700
Message-ID: <1490412818.24891.9.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170324164902.15226.48358.stgit@localhost.localdomain>
         <20170324170830.15226.9932.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexander Duyck <alexander.duyck-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170324170830.15226.9932.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-03-24 at 10:08 -0700, Alexander Duyck wrote:
> From: Sridhar Samudrala <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> 
> This patch adds busy poll support to epoll. The implementation is meant to
> be opportunistic in that it will take the NAPI ID from the last socket
> that is added to the ready list that contains a valid NAPI ID and it will
> use that for busy polling until the ready list goes empty.  Once the ready
> list goes empty the NAPI ID is reset and busy polling is disabled until a
> new socket is added to the ready list.
> 
> In addition when we insert a new socket into the epoll we record the NAPI
> ID and assume we are going to receive events on it.  If that doesn't occur
> it will be evicted as the active NAPI ID and we will resume normal
> behavior.
> 
> An application can use SO_INCOMING_CPU or SO_REUSEPORT_ATTACH_C/EBPF socket
> options to spread the incoming connections to specific worker threads
> based on the incoming queue. This enables epoll for each worker thread
> to have only sockets that receive packets from a single queue. So when an
> application calls epoll_wait() and there are no events available to report,
> busy polling is done on the associated queue to pull the packets.
> 
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> Signed-off-by: Alexander Duyck <alexander.h.duyck-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
> ---
>  fs/eventpoll.c |   93 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 93 insertions(+)

Acked-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
