From: kbuild test robot <lkp-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] sunrpc: fix waitqueue_active without memory barrier in
 sunrpc
Date: Fri, 9 Oct 2015 09:11:27 +0800
Message-ID: <201510090901.oXMifuia%fengguang.wu@intel.com>
References: <17EC94B0A072C34B8DCF0D30AD16044A028747A3@BPXM09GP.gisp.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all-JC7UmRfGjtg@public.gmane.org,
	Trond Myklebust <trond.myklebust-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>,
	Anna Schumaker <anna.schumaker-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org>,
	"J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>,
	Jeff Layton <jlayton-vpEMnDpepFuMZCB2o+C8xQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kosuke Tatsukawa <tatsu-zZGIbrA41Td8UrSeD/g0lQ@public.gmane.org>
Return-path: <linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <17EC94B0A072C34B8DCF0D30AD16044A028747A3-9lrffkYxhwTt6d3pZDjeaEtBU8KWyXPq@public.gmane.org>
Sender: linux-nfs-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Kosuke,

[auto build test WARNING on v4.3-rc4 -- if it's inappropriate base, please ignore]

reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> net/sunrpc/svcsock.c:417:28: sparse: incorrect type in argument 1 (different base types)
   net/sunrpc/svcsock.c:417:28:    expected struct socket_wq *wq
   net/sunrpc/svcsock.c:417:28:    got struct __wait_queue_head [usertype] *wq
>> net/sunrpc/svcsock.c:1597:28: sparse: incorrect type in argument 1 (different base types)
   net/sunrpc/svcsock.c:1597:28:    expected struct socket_wq *wq
   net/sunrpc/svcsock.c:1597:28:    got struct __wait_queue_head [usertype] *[assigned] wq
   net/sunrpc/svcsock.c:435:28: sparse: incorrect type in argument 1 (different base types)
   net/sunrpc/svcsock.c:435:28:    expected struct socket_wq *wq
   net/sunrpc/svcsock.c:435:28:    got struct __wait_queue_head [usertype] *wq
   net/sunrpc/svcsock.c:790:28: sparse: incorrect type in argument 1 (different base types)
   net/sunrpc/svcsock.c:790:28:    expected struct socket_wq *wq
   net/sunrpc/svcsock.c:790:28:    got struct __wait_queue_head [usertype] *[assigned] wq
   net/sunrpc/svcsock.c:811:28: sparse: incorrect type in argument 1 (different base types)
   net/sunrpc/svcsock.c:811:28:    expected struct socket_wq *wq
   net/sunrpc/svcsock.c:811:28:    got struct __wait_queue_head [usertype] *wq
   net/sunrpc/svcsock.c:826:28: sparse: incorrect type in argument 1 (different base types)
   net/sunrpc/svcsock.c:826:28:    expected struct socket_wq *wq
   net/sunrpc/svcsock.c:826:28:    got struct __wait_queue_head [usertype] *wq
   net/sunrpc/svcsock.c: In function 'svc_udp_data_ready':
   net/sunrpc/svcsock.c:417:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   net/sunrpc/svcsock.c: In function 'svc_write_space':
   net/sunrpc/svcsock.c:435:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq)) {
                        ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   net/sunrpc/svcsock.c: In function 'svc_tcp_listen_data_ready':
   net/sunrpc/svcsock.c:790:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   net/sunrpc/svcsock.c: In function 'svc_tcp_state_change':
   net/sunrpc/svcsock.c:811:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   net/sunrpc/svcsock.c: In function 'svc_tcp_data_ready':
   net/sunrpc/svcsock.c:826:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^
   net/sunrpc/svcsock.c: In function 'svc_sock_detach':
   net/sunrpc/svcsock.c:1597:21: warning: passing argument 1 of 'wq_has_sleeper' from incompatible pointer type [-Wincompatible-pointer-types]
     if (wq_has_sleeper(wq))
                        ^
   In file included from include/net/inet_sock.h:27:0,
                    from include/linux/udp.h:20,
                    from net/sunrpc/svcsock.c:30:
   include/net/sock.h:1879:20: note: expected 'struct socket_wq *' but argument is of type 'wait_queue_head_t * {aka struct __wait_queue_head *}'
    static inline bool wq_has_sleeper(struct socket_wq *wq)
                       ^

vim +417 net/sunrpc/svcsock.c

   401	
   402	/*
   403	 * INET callback when data has been received on the socket.
   404	 */
   405	static void svc_udp_data_ready(struct sock *sk)
   406	{
   407		struct svc_sock	*svsk = (struct svc_sock *)sk->sk_user_data;
   408		wait_queue_head_t *wq = sk_sleep(sk);
   409	
   410		if (svsk) {
   411			dprintk("svc: socket %p(inet %p), busy=%d\n",
   412				svsk, sk,
   413				test_bit(XPT_BUSY, &svsk->sk_xprt.xpt_flags));
   414			set_bit(XPT_DATA, &svsk->sk_xprt.xpt_flags);
   415			svc_xprt_enqueue(&svsk->sk_xprt);
   416		}
 > 417		if (wq_has_sleeper(wq))
   418			wake_up_interruptible(wq);
   419	}
   420	
   421	/*
   422	 * INET callback when space is newly available on the socket.
   423	 */
   424	static void svc_write_space(struct sock *sk)
   425	{

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
--
To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
