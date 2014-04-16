From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/19] NET: set PF_FSTRANS while holding sk_lock
Date: Tue, 15 Apr 2014 22:13:46 -0700
Message-ID: <1397625226.4222.113.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140416033623.10604.69237.stgit@notabene.brown>
	 <20140416040336.10604.96000.stgit@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, xfs-VZNHf3L845pBDgjK7y7TUQ@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: NeilBrown <neilb-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140416040336.10604.96000.stgit-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2014-04-16 at 14:03 +1000, NeilBrown wrote:
> sk_lock can be taken while reclaiming memory (in nfsd for loop-back
> NFS mounts, and presumably in nfs), and memory can be allocated while
> holding sk_lock, at least via:
> 
>  inet_listen -> inet_csk_listen_start ->reqsk_queue_alloc
> 
> So to avoid deadlocks, always set PF_FSTRANS while holding sk_lock.
> 
> This deadlock was found by lockdep.

Wow, this is adding expensive stuff in fast path, only for nfsd :(

BTW, why should the current->flags should be saved on a socket field,
and not a current->save_flags. This really looks a thread property, not
a socket one.

Why nfsd could not have PF_FSTRANS in its current->flags ?

For applications handling millions of sockets, this makes a difference.


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
