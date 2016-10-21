From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v6 2/3] udp: implement memory accounting helpers
Date: Fri, 21 Oct 2016 06:41:35 -0700
Message-ID: <1477057295.7065.68.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1477043395.git.pabeni@redhat.com>
         <4d2e0fc8f5c3d1309b0fb71bc65a2719a8e82825.1477043395.git.pabeni@redhat.com>
         <1477052642.7065.63.camel@edumazet-glaptop3.roam.corp.google.com>
         <1477056841.4606.36.camel@redhat.com>
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
In-Reply-To: <1477056841.4606.36.camel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-10-21 at 15:34 +0200, Paolo Abeni wrote:

> Updating sk_rmem_alloc would still need an atomic operation,
> because it is touched also by the error queue path: we will end up
> adding an atomic operation (or two, when reclaiming the fwd allocated
> memory) inside the critical section. The contention will likely
> increase.
> 
> The above is going to be quite intrusive: we need to pass an
> additional argument all the way up to __skb_try_recv_datagram() and
> change the function behavior according to its value.
> 
> If you are otherwise satisfied with the series in the current shape,
> can't we instead build incrementally on top of it ? it will simplify
> both reviews and re-factor tasks.

I certainly can provide an incremental patch, it might be easier for
both of us ;)



--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
