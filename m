From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next v2 3/3] udp: use it's own memory accounting
 schema
Date: Tue, 27 Sep 2016 11:42:14 -0700
Message-ID: <1475001734.28155.62.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1474995024.git.pabeni@redhat.com>
         <bc55b0885e0f93895c211168561a6b3403bade10.1474995024.git.pabeni@redhat.com>
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
In-Reply-To: <bc55b0885e0f93895c211168561a6b3403bade10.1474995024.git.pabeni-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 2016-09-27 at 18:58 +0200, Paolo Abeni wrote:


> 
> Since the new memory accounting model does not require socket
> locking, remove the lock on enqueue and free and avoid using the
> backlog on enqueue.


...

>  	__UDP_INC_STATS(sock_net(sk), UDP_MIB_CSUMERRORS, is_udplite);
> @@ -2345,6 +2325,7 @@ struct proto udp_prot = {
>  	.connect	   = ip4_datagram_connect,
>  	.disconnect	   = udp_disconnect,
>  	.ioctl		   = udp_ioctl,
> +	.init		   = udp_init_sock,
>  	.destroy	   = udp_destroy_sock,
>  	.setsockopt	   = udp_setsockopt,
>  	.getsockopt	   = udp_getsockopt,
> @@ -2357,7 +2338,10 @@ struct proto udp_prot = {
>  	.unhash		   = udp_lib_unhash,
>  	.rehash		   = udp_v4_rehash,
>  	.get_port	   = udp_v4_get_port,
> +	.enter_memory_pressure = udp_enter_memory_pressure,
> +	.sockets_allocated = &udp_sockets_allocated,
>  	.memory_allocated  = &udp_memory_allocated,
> +	.memory_pressure   = &udp_memory_pressure,
>  	.sysctl_mem	   = sysctl_udp_mem,
>  	.sysctl_wmem	   = &sysctl_udp_wmem_min,
>  	.sysctl_rmem	   = &sysctl_udp_rmem_min,


I find disturbing you did not remove 

	.backlog_rcv       = __udp_queue_rcv_skb,


--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
