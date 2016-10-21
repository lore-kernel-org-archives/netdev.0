From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v6 3/3] udp: use it's own memory accounting
 schema
Date: Fri, 21 Oct 2016 14:14:38 -0700
Message-ID: <1477084478.7065.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1477043395.git.pabeni@redhat.com>
         <530de0874eb7bbe1dbdaa4e8ccbb56d917ee598f.1477043395.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <jmorris-gx6/JNMH7DfYtjvyW6yDsg@public.gmane.org>,
        Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
        Alexander Duyck <aduyck-nYU0QVwCCFFWk0Htik3J/w@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Tom Herbert <tom-BjP2VixgY4xUbtYUoyoikg@public.gmane.org>,
        Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
        Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Paolo Abeni <pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <530de0874eb7bbe1dbdaa4e8ccbb56d917ee598f.1477043395.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-21 at 13:55 +0200, Paolo Abeni wrote:
> Completely avoid default sock memory accounting and replace it
> with udp-specific accounting.
> 
> Since the new memory accounting model encapsulates completely
> the required locking, remove the socket lock on both enqueue and
> dequeue, and avoid using the backlog on enqueue.
> 
> Be sure to clean-up rx queue memory on socket destruction, using
> udp its own sk_destruct.
> 
> Tested using pktgen with random src port, 64 bytes packet,
> wire-speed on a 10G link as sender and udp_sink as the receiver,
> using an l4 tuple rxhash to stress the contention, and one or more
> udp_sink instances with reuseport.
> 
> nr readers      Kpps (vanilla)  Kpps (patched)
> 1               170             440

Acked-by: Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>

Thanks a lot guys.


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
