From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] Net: core: sock.c coding style fixes
Date: Tue, 15 Sep 2015 13:22:48 -0500
Message-ID: <87mvwnbkzr.fsf@x220.int.ebiederm.org>
References: <1442339925-17079-1-git-send-email-cristos@vipserv.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, edumazet@google.com, netdev@vger.kernel.org
To: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:33843 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751806AbbIOSaL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 14:30:11 -0400
In-Reply-To: <1442339925-17079-1-git-send-email-cristos@vipserv.org>
	(Krzysztof Majzerowicz-Jaszcz's message of "Tue, 15 Sep 2015 19:58:45
	+0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org> writes:

> Fixed most coding style issues reported by checkpatch.pl

Ugh.  At least in the matter of comments I find this patch makes
the code uglier.

Replacing:
/*
 *             Important banner about the code
 */

with
 /* Important banner about the code */

Does not look as nice and does not convey the same information as
clearly.

Remember checkpatch.pl is not the ruler or the rules it is a servant
with a bunch of heuristics to point out problems.

Eric

> Signed-off-by: Krzysztof Majzerowicz-Jaszcz <cristos@vipserv.org>
> ---
>  net/core/sock.c | 442 +++++++++++++++++++++++++-------------------------------
>  1 file changed, 200 insertions(+), 242 deletions(-)
>
> diff --git a/net/core/sock.c b/net/core/sock.c
> index ca2984a..d17cc5d 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -66,7 +66,7 @@
>   *		Alan Cox	:	Allocator for a socket is settable.
>   *		Alan Cox	:	SO_ERROR includes soft errors.
>   *		Alan Cox	:	Allow NULL arguments on some SO_ opts
> - *		Alan Cox	: 	Generic socket allocation to make hooks
> + *		Alan Cox	:	Generic socket allocation to make hooks
>   *					easier (suggested by Craig Metz).
>   *		Michael Pall	:	SO_ERROR returns positive errno again
>   *              Steve Whitehouse:       Added default destructor to free
> @@ -118,7 +118,7 @@
>  #include <linux/memcontrol.h>
>  #include <linux/prefetch.h>
>  
> -#include <asm/uaccess.h>
> +#include <linux/uaccess.h>
>  
>  #include <linux/netdevice.h>
>  #include <net/protocol.h>
> @@ -194,7 +194,6 @@ bool sk_net_capable(const struct sock *sk, int cap)
>  }
>  EXPORT_SYMBOL(sk_net_capable);
>  
> -
>  #ifdef CONFIG_MEMCG_KMEM
>  int mem_cgroup_sockets_init(struct mem_cgroup *memcg, struct cgroup_subsys *ss)
>  {
> @@ -232,8 +231,7 @@ void mem_cgroup_sockets_destroy(struct mem_cgroup *memcg)
>  }
>  #endif
>  
> -/*
> - * Each address family might have different locking rules, so we have
> +/* Each address family might have different locking rules, so we have
>   * one slock key per address family:
>   */
>  static struct lock_class_key af_family_keys[AF_MAX];
> @@ -244,62 +242,62 @@ struct static_key memcg_socket_limit_enabled;
>  EXPORT_SYMBOL(memcg_socket_limit_enabled);
>  #endif
>  
> -/*
> - * Make lock validator output more readable. (we pre-construct these
> +/* Make lock validator output more readable. (we pre-construct these
>   * strings build-time, so that runtime initialization of socket
>   * locks is fast):
>   */
> -static const char *const af_family_key_strings[AF_MAX+1] = {
> -  "sk_lock-AF_UNSPEC", "sk_lock-AF_UNIX"     , "sk_lock-AF_INET"     ,
> -  "sk_lock-AF_AX25"  , "sk_lock-AF_IPX"      , "sk_lock-AF_APPLETALK",
> -  "sk_lock-AF_NETROM", "sk_lock-AF_BRIDGE"   , "sk_lock-AF_ATMPVC"   ,
> -  "sk_lock-AF_X25"   , "sk_lock-AF_INET6"    , "sk_lock-AF_ROSE"     ,
> -  "sk_lock-AF_DECnet", "sk_lock-AF_NETBEUI"  , "sk_lock-AF_SECURITY" ,
> -  "sk_lock-AF_KEY"   , "sk_lock-AF_NETLINK"  , "sk_lock-AF_PACKET"   ,
> -  "sk_lock-AF_ASH"   , "sk_lock-AF_ECONET"   , "sk_lock-AF_ATMSVC"   ,
> -  "sk_lock-AF_RDS"   , "sk_lock-AF_SNA"      , "sk_lock-AF_IRDA"     ,
> -  "sk_lock-AF_PPPOX" , "sk_lock-AF_WANPIPE"  , "sk_lock-AF_LLC"      ,
> -  "sk_lock-27"       , "sk_lock-28"          , "sk_lock-AF_CAN"      ,
> -  "sk_lock-AF_TIPC"  , "sk_lock-AF_BLUETOOTH", "sk_lock-IUCV"        ,
> -  "sk_lock-AF_RXRPC" , "sk_lock-AF_ISDN"     , "sk_lock-AF_PHONET"   ,
> -  "sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF" , "sk_lock-AF_ALG"      ,
> -  "sk_lock-AF_NFC"   , "sk_lock-AF_VSOCK"    , "sk_lock-AF_MAX"
> +static const char *const af_family_key_strings[AF_MAX + 1] = {
> +	"sk_lock-AF_UNSPEC",	"sk_lock-AF_UNIX",	"sk_lock-AF_INET",
> +	"sk_lock-AF_AX25",	"sk_lock-AF_IPX",	"sk_lock-AF_APPLETALK",
> +	"sk_lock-AF_NETROM",	"sk_lock-AF_BRIDGE",	"sk_lock-AF_ATMPVC",
> +	"sk_lock-AF_X25",	"sk_lock-AF_INET6",	"sk_lock-AF_ROSE",
> +	"sk_lock-AF_DECnet",	"sk_lock-AF_NETBEUI",	"sk_lock-AF_SECURITY",
> +	"sk_lock-AF_KEY",	"sk_lock-AF_NETLINK",	"sk_lock-AF_PACKET",
> +	"sk_lock-AF_ASH",	"sk_lock-AF_ECONET",	"sk_lock-AF_ATMSVC",
> +	"sk_lock-AF_RDS",	"sk_lock-AF_SNA",	"sk_lock-AF_IRDA",
> +	"sk_lock-AF_PPPOX",	"sk_lock-AF_WANPIPE",	"sk_lock-AF_LLC",
> +	"sk_lock-27",		"sk_lock-28",		"sk_lock-AF_CAN",
> +	"sk_lock-AF_TIPC",	"sk_lock-AF_BLUETOOTH",	"sk_lock-IUCV",
> +	"sk_lock-AF_RXRPC",	"sk_lock-AF_ISDN",	"sk_lock-AF_PHONET",
> +	"sk_lock-AF_IEEE802154", "sk_lock-AF_CAIF",	"sk_lock-AF_ALG",
> +	"sk_lock-AF_NFC",	"sk_lock-AF_VSOCK",	"sk_lock-AF_MAX"
>  };
> -static const char *const af_family_slock_key_strings[AF_MAX+1] = {
> -  "slock-AF_UNSPEC", "slock-AF_UNIX"     , "slock-AF_INET"     ,
> -  "slock-AF_AX25"  , "slock-AF_IPX"      , "slock-AF_APPLETALK",
> -  "slock-AF_NETROM", "slock-AF_BRIDGE"   , "slock-AF_ATMPVC"   ,
> -  "slock-AF_X25"   , "slock-AF_INET6"    , "slock-AF_ROSE"     ,
> -  "slock-AF_DECnet", "slock-AF_NETBEUI"  , "slock-AF_SECURITY" ,
> -  "slock-AF_KEY"   , "slock-AF_NETLINK"  , "slock-AF_PACKET"   ,
> -  "slock-AF_ASH"   , "slock-AF_ECONET"   , "slock-AF_ATMSVC"   ,
> -  "slock-AF_RDS"   , "slock-AF_SNA"      , "slock-AF_IRDA"     ,
> -  "slock-AF_PPPOX" , "slock-AF_WANPIPE"  , "slock-AF_LLC"      ,
> -  "slock-27"       , "slock-28"          , "slock-AF_CAN"      ,
> -  "slock-AF_TIPC"  , "slock-AF_BLUETOOTH", "slock-AF_IUCV"     ,
> -  "slock-AF_RXRPC" , "slock-AF_ISDN"     , "slock-AF_PHONET"   ,
> -  "slock-AF_IEEE802154", "slock-AF_CAIF" , "slock-AF_ALG"      ,
> -  "slock-AF_NFC"   , "slock-AF_VSOCK"    ,"slock-AF_MAX"
> +
> +static const char *const af_family_slock_key_strings[AF_MAX + 1] = {
> +	"slock-AF_UNSPEC",	"slock-AF_UNIX",	"slock-AF_INET",
> +	"slock-AF_AX25",	"slock-AF_IPX",		"slock-AF_APPLETALK",
> +	"slock-AF_NETROM",	"slock-AF_BRIDGE",	"slock-AF_ATMPVC",
> +	"slock-AF_X25",		"slock-AF_INET6",	"slock-AF_ROSE",
> +	"slock-AF_DECnet",	"slock-AF_NETBEUI",	"slock-AF_SECURITY",
> +	"slock-AF_KEY",		"slock-AF_NETLINK",	"slock-AF_PACKET",
> +	"slock-AF_ASH",		"slock-AF_ECONET",	"slock-AF_ATMSVC",
> +	"slock-AF_RDS",		"slock-AF_SNA",		"slock-AF_IRDA",
> +	"slock-AF_PPPOX",	"slock-AF_WANPIPE",	"slock-AF_LLC",
> +	"slock-27",		"slock-28",		"slock-AF_CAN",
> +	"slock-AF_TIPC",	"slock-AF_BLUETOOTH",	"slock-AF_IUCV",
> +	"slock-AF_RXRPC",	"slock-AF_ISDN",	"slock-AF_PHONET",
> +	"slock-AF_IEEE802154",	"slock-AF_CAIF",	"slock-AF_ALG",
> +	"slock-AF_NFC",		"slock-AF_VSOCK",	"slock-AF_MAX"
>  };
> -static const char *const af_family_clock_key_strings[AF_MAX+1] = {
> -  "clock-AF_UNSPEC", "clock-AF_UNIX"     , "clock-AF_INET"     ,
> -  "clock-AF_AX25"  , "clock-AF_IPX"      , "clock-AF_APPLETALK",
> -  "clock-AF_NETROM", "clock-AF_BRIDGE"   , "clock-AF_ATMPVC"   ,
> -  "clock-AF_X25"   , "clock-AF_INET6"    , "clock-AF_ROSE"     ,
> -  "clock-AF_DECnet", "clock-AF_NETBEUI"  , "clock-AF_SECURITY" ,
> -  "clock-AF_KEY"   , "clock-AF_NETLINK"  , "clock-AF_PACKET"   ,
> -  "clock-AF_ASH"   , "clock-AF_ECONET"   , "clock-AF_ATMSVC"   ,
> -  "clock-AF_RDS"   , "clock-AF_SNA"      , "clock-AF_IRDA"     ,
> -  "clock-AF_PPPOX" , "clock-AF_WANPIPE"  , "clock-AF_LLC"      ,
> -  "clock-27"       , "clock-28"          , "clock-AF_CAN"      ,
> -  "clock-AF_TIPC"  , "clock-AF_BLUETOOTH", "clock-AF_IUCV"     ,
> -  "clock-AF_RXRPC" , "clock-AF_ISDN"     , "clock-AF_PHONET"   ,
> -  "clock-AF_IEEE802154", "clock-AF_CAIF" , "clock-AF_ALG"      ,
> -  "clock-AF_NFC"   , "clock-AF_VSOCK"    , "clock-AF_MAX"
> +
> +static const char *const af_family_clock_key_strings[AF_MAX + 1] = {
> +	"clock-AF_UNSPEC",	"clock-AF_UNIX",	"clock-AF_INET",
> +	"clock-AF_AX25",	"clock-AF_IPX",		"clock-AF_APPLETALK",
> +	"clock-AF_NETROM",	"clock-AF_BRIDGE",	"clock-AF_ATMPVC",
> +	"clock-AF_X25",		"clock-AF_INET6",	"clock-AF_ROSE",
> +	"clock-AF_DECnet",	"clock-AF_NETBEUI",	"clock-AF_SECURITY",
> +	"clock-A-F_KEY",	"clock-AF_NETLINK",	"clock-AF_PACKET",
> +	"clock-AF_ASH",		"clock-AF_ECONET",	"clock-AF_ATMSVC",
> +	"clock-AF_RDS",		"clock-AF_SNA",		"clock-AF_IRDA",
> +	"clock-AF_PPPOX",	"clock-AF_WANPIPE",	"clock-AF_LLC",
> +	"clock-27",		"clock-28",		"clock-AF_CAN",
> +	"clock-AF_TIPC",	"clock-AF_BLUETOOTH",	"clock-AF_IUCV",
> +	"clock-AF_RXRPC",	"clock-AF_ISDN",	"clock-AF_PHONET",
> +	"clock-AF_IEEE802154",	"clock-AF_CAIF",	"clock-AF_ALG",
> +	"clock-AF_NFC",		"clock-AF_VSOCK",	"clock-AF_MAX"
>  };
>  
> -/*
> - * sk_callback_lock locking rules are per-address-family,
> +/* sk_callback_lock locking rules are per-address-family,
>   * so split the lock classes by using a per-AF key:
>   */
>  static struct lock_class_key af_callback_keys[AF_MAX];
> @@ -323,7 +321,7 @@ __u32 sysctl_wmem_default __read_mostly = SK_WMEM_MAX;
>  __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
>  
>  /* Maximal space eaten by iovec or ancillary data plus some space */
> -int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
> +int sysctl_optmem_max __read_mostly = sizeof(unsigned long) * (2 * UIO_MAXIOV + 512);
>  EXPORT_SYMBOL(sysctl_optmem_max);
>  
>  int sysctl_tstamp_allow_data __read_mostly = 1;
> @@ -353,8 +351,7 @@ void sk_clear_memalloc(struct sock *sk)
>  	sk->sk_allocation &= ~__GFP_MEMALLOC;
>  	static_key_slow_dec(&memalloc_socks);
>  
> -	/*
> -	 * SOCK_MEMALLOC is allowed to ignore rmem limits to ensure forward
> +	/* SOCK_MEMALLOC is allowed to ignore rmem limits to ensure forward
>  	 * progress of swapping. SOCK_MEMALLOC may be cleared while
>  	 * it has rmem allocations due to the last swapfile being deactivated
>  	 * but there is a risk that the socket is unusable due to exceeding
> @@ -405,8 +402,9 @@ static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
>  	*timeo_p = MAX_SCHEDULE_TIMEOUT;
>  	if (tv.tv_sec == 0 && tv.tv_usec == 0)
>  		return 0;
> -	if (tv.tv_sec < (MAX_SCHEDULE_TIMEOUT/HZ - 1))
> -		*timeo_p = tv.tv_sec*HZ + (tv.tv_usec+(1000000/HZ-1))/(1000000/HZ);
> +	if (tv.tv_sec < (MAX_SCHEDULE_TIMEOUT / HZ - 1))
> +		*timeo_p = tv.tv_sec * HZ + (tv.tv_usec + (1000000 / HZ - 1)) /
> +					    (1000000 / HZ);
>  	return 0;
>  }
>  
> @@ -414,6 +412,7 @@ static void sock_warn_obsolete_bsdism(const char *name)
>  {
>  	static int warned;
>  	static char warncomm[TASK_COMM_LEN];
> +
>  	if (strcmp(warncomm, current->comm) && warned < 5) {
>  		strcpy(warncomm,  current->comm);
>  		pr_warn("process `%s' is using obsolete %s SO_BSDCOMPAT\n",
> @@ -422,7 +421,8 @@ static void sock_warn_obsolete_bsdism(const char *name)
>  	}
>  }
>  
> -#define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) | (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
> +#define SK_FLAGS_TIMESTAMP ((1UL << SOCK_TIMESTAMP) |\
> +			    (1UL << SOCK_TIMESTAMPING_RX_SOFTWARE))
>  
>  static void sock_disable_timestamp(struct sock *sk, unsigned long flags)
>  {
> @@ -433,7 +433,6 @@ static void sock_disable_timestamp(struct sock *sk, unsigned long flags)
>  	}
>  }
>  
> -
>  int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
>  {
>  	int err;
> @@ -492,8 +491,7 @@ int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
>  	else
>  		bh_lock_sock(sk);
>  	if (!sock_owned_by_user(sk)) {
> -		/*
> -		 * trylock + unlock semantics:
> +		/* trylock + unlock semantics:
>  		 */
>  		mutex_acquire(&sk->sk_lock.dep_map, 0, 1, _RET_IP_);
>  
> @@ -520,7 +518,7 @@ struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
>  {
>  	struct dst_entry *dst = __sk_dst_get(sk);
>  
> -	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
> +	if (dst && dst->obsolete && !dst->ops->check(dst, cookie)) {
>  		sk_tx_queue_clear(sk);
>  		RCU_INIT_POINTER(sk->sk_dst_cache, NULL);
>  		dst_release(dst);
> @@ -535,7 +533,7 @@ struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie)
>  {
>  	struct dst_entry *dst = sk_dst_get(sk);
>  
> -	if (dst && dst->obsolete && dst->ops->check(dst, cookie) == NULL) {
> +	if (dst && dst->obsolete && !dst->ops->check(dst, cookie)) {
>  		sk_dst_reset(sk);
>  		dst_release(dst);
>  		return NULL;
> @@ -670,9 +668,8 @@ bool sk_mc_loop(struct sock *sk)
>  }
>  EXPORT_SYMBOL(sk_mc_loop);
>  
> -/*
> - *	This is meant for all protocols to use and covers goings on
> - *	at the socket level. Everything here is generic.
> +/* This is meant for all protocols to use and covers goings on
> + * at the socket level. Everything here is generic.
>   */
>  
>  int sock_setsockopt(struct socket *sock, int level, int optname,
> @@ -684,9 +681,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
>  	struct linger ling;
>  	int ret = 0;
>  
> -	/*
> -	 *	Options without arguments
> -	 */
> +	/* Options without arguments */
>  
>  	if (optname == SO_BINDTODEVICE)
>  		return sock_setbindtodevice(sk, optval, optlen);
> @@ -756,8 +751,7 @@ set_sndbuf:
>  		val = min_t(u32, val, sysctl_rmem_max);
>  set_rcvbuf:
>  		sk->sk_userlocks |= SOCK_RCVBUF_LOCK;
> -		/*
> -		 * We double it on the way in to account for
> +		/* We double it on the way in to account for
>  		 * "struct sk_buff" etc. overhead.   Applications
>  		 * assume that the SO_RCVBUF setting they make will
>  		 * allow that much actual data to be received on that
> @@ -815,11 +809,11 @@ set_rcvbuf:
>  			ret = -EFAULT;
>  			break;
>  		}
> -		if (!ling.l_onoff)
> +		if (!ling.l_onoff) {
>  			sock_reset_flag(sk, SOCK_LINGER);
> -		else {
> +		} else {
>  #if (BITS_PER_LONG == 32)
> -			if ((unsigned int)ling.l_linger >= MAX_SCHEDULE_TIMEOUT/HZ)
> +			if ((unsigned int)ling.l_linger >= MAX_SCHEDULE_TIMEOUT / HZ)
>  				sk->sk_lingertime = MAX_SCHEDULE_TIMEOUT;
>  			else
>  #endif
> @@ -971,9 +965,9 @@ set_rcvbuf:
>  #ifdef CONFIG_NET_RX_BUSY_POLL
>  	case SO_BUSY_POLL:
>  		/* allow unprivileged users to decrease the value */
> -		if ((val > sk->sk_ll_usec) && !capable(CAP_NET_ADMIN))
> +		if ((val > sk->sk_ll_usec) && !capable(CAP_NET_ADMIN)) {
>  			ret = -EPERM;
> -		else {
> +		} else {
>  			if (val < 0)
>  				ret = -EINVAL;
>  			else
> @@ -997,12 +991,12 @@ set_rcvbuf:
>  }
>  EXPORT_SYMBOL(sock_setsockopt);
>  
> -
>  static void cred_to_ucred(struct pid *pid, const struct cred *cred,
>  			  struct ucred *ucred)
>  {
>  	ucred->pid = pid_vnr(pid);
> -	ucred->uid = ucred->gid = -1;
> +	ucred->uid = -1;
> +	ucred->gid = -1;
>  	if (cred) {
>  		struct user_namespace *current_ns = current_user_ns();
>  
> @@ -1155,6 +1149,7 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
>  	case SO_PEERCRED:
>  	{
>  		struct ucred peercred;
> +
>  		if (len > sizeof(peercred))
>  			len = sizeof(peercred);
>  		cred_to_ucred(sk->sk_peer_pid, sk->sk_peer_cred, &peercred);
> @@ -1167,7 +1162,8 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
>  	{
>  		char address[128];
>  
> -		if (sock->ops->getname(sock, (struct sockaddr *)address, &lv, 2))
> +		if (sock->ops->getname(sock, (struct sockaddr *)address,
> +				       &lv, 2))
>  			return -ENOTCONN;
>  		if (lv < len)
>  			return -EINVAL;
> @@ -1188,7 +1184,8 @@ int sock_getsockopt(struct socket *sock, int level, int optname,
>  		break;
>  
>  	case SO_PEERSEC:
> -		return security_socket_getpeersec_stream(sock, optval, optlen, len);
> +		return security_socket_getpeersec_stream(sock, optval, optlen,
> +							 len);
>  
>  	case SO_MARK:
>  		v.val = sk->sk_mark;
> @@ -1265,8 +1262,7 @@ lenout:
>  	return 0;
>  }
>  
> -/*
> - * Initialize an sk_lock.
> +/* Initialize an sk_lock.
>   *
>   * (We also register the sk_lock with the lock validator.)
>   */
> @@ -1279,8 +1275,7 @@ static inline void sock_lock_init(struct sock *sk)
>  			af_family_keys + sk->sk_family);
>  }
>  
> -/*
> - * Copy all fields from osk to nsk but nsk->sk_refcnt must not change yet,
> +/* Copy all fields from osk to nsk but nsk->sk_refcnt must not change yet,
>   * even temporarly, because of RCU lookups. sk_node should also be left as is.
>   * We must not copy fields between sk_dontcopy_begin and sk_dontcopy_end
>   */
> @@ -1319,13 +1314,13 @@ void sk_prot_clear_portaddr_nulls(struct sock *sk, int size)
>  EXPORT_SYMBOL(sk_prot_clear_portaddr_nulls);
>  
>  static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
> -		int family)
> +				  int family)
>  {
>  	struct sock *sk;
>  	struct kmem_cache *slab;
>  
>  	slab = prot->slab;
> -	if (slab != NULL) {
> +	if (slab) {
>  		sk = kmem_cache_alloc(slab, priority & ~__GFP_ZERO);
>  		if (!sk)
>  			return sk;
> @@ -1335,10 +1330,10 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
>  			else
>  				sk_prot_clear_nulls(sk, prot->obj_size);
>  		}
> -	} else
> +	} else {
>  		sk = kmalloc(prot->obj_size, priority);
> -
> -	if (sk != NULL) {
> +	}
> +	if (sk) {
>  		kmemcheck_annotate_bitfield(sk, flags);
>  
>  		if (security_sk_alloc(sk, family, priority))
> @@ -1354,7 +1349,7 @@ static struct sock *sk_prot_alloc(struct proto *prot, gfp_t priority,
>  out_free_sec:
>  	security_sk_free(sk);
>  out_free:
> -	if (slab != NULL)
> +	if (slab)
>  		kmem_cache_free(slab, sk);
>  	else
>  		kfree(sk);
> @@ -1370,7 +1365,7 @@ static void sk_prot_free(struct proto *prot, struct sock *sk)
>  	slab = prot->slab;
>  
>  	security_sk_free(sk);
> -	if (slab != NULL)
> +	if (slab)
>  		kmem_cache_free(slab, sk);
>  	else
>  		kfree(sk);
> @@ -1404,11 +1399,11 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
>  	sk = sk_prot_alloc(prot, priority | __GFP_ZERO, family);
>  	if (sk) {
>  		sk->sk_family = family;
> -		/*
> -		 * See comment in struct sock definition to understand
> +		/* See comment in struct sock definition to understand
>  		 * why we need sk_prot_creator -acme
>  		 */
> -		sk->sk_prot = sk->sk_prot_creator = prot;
> +		sk->sk_prot_creator = prot;
> +		sk->sk_prot = sk->sk_prot_creator;
>  		sock_lock_init(sk);
>  		sk->sk_net_refcnt = kern ? 0 : 1;
>  		if (likely(sk->sk_net_refcnt))
> @@ -1462,8 +1457,7 @@ static void __sk_free(struct sock *sk)
>  
>  void sk_free(struct sock *sk)
>  {
> -	/*
> -	 * We subtract one from sk_wmem_alloc and can know if
> +	/* We subtract one from sk_wmem_alloc and can know if
>  	 * some packets are still in some tx queue.
>  	 * If not null, sock_wfree() will call __sk_free(sk) later
>  	 */
> @@ -1491,7 +1485,7 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  	bool is_charged = true;
>  
>  	newsk = sk_prot_alloc(sk->sk_prot, priority, sk->sk_family);
> -	if (newsk != NULL) {
> +	if (newsk) {
>  		struct sk_filter *filter;
>  
>  		sock_copy(newsk, sk);
> @@ -1502,13 +1496,13 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  		sk_node_init(&newsk->sk_node);
>  		sock_lock_init(newsk);
>  		bh_lock_sock(newsk);
> -		newsk->sk_backlog.head	= newsk->sk_backlog.tail = NULL;
> +		newsk->sk_backlog.head = NULL;
> +		newsk->sk_backlog.tail = NULL;
>  		newsk->sk_backlog.len = 0;
>  
>  		atomic_set(&newsk->sk_rmem_alloc, 0);
> -		/*
> -		 * sk_wmem_alloc set to one (see sk_free() and sock_wfree())
> -		 */
> +
> +		/* sk_wmem_alloc set to one (see sk_free() and sock_wfree()) */
>  		atomic_set(&newsk->sk_wmem_alloc, 1);
>  		atomic_set(&newsk->sk_omem_alloc, 0);
>  		skb_queue_head_init(&newsk->sk_receive_queue);
> @@ -1520,17 +1514,17 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  				af_callback_keys + newsk->sk_family,
>  				af_family_clock_key_strings[newsk->sk_family]);
>  
> -		newsk->sk_dst_cache	= NULL;
> -		newsk->sk_wmem_queued	= 0;
> +		newsk->sk_dst_cache = NULL;
> +		newsk->sk_wmem_queued = 0;
>  		newsk->sk_forward_alloc = 0;
> -		newsk->sk_send_head	= NULL;
> -		newsk->sk_userlocks	= sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
> +		newsk->sk_send_head = NULL;
> +		newsk->sk_userlocks = sk->sk_userlocks & ~SOCK_BINDPORT_LOCK;
>  
>  		sock_reset_flag(newsk, SOCK_DONE);
>  		skb_queue_head_init(&newsk->sk_error_queue);
>  
>  		filter = rcu_dereference_protected(newsk->sk_filter, 1);
> -		if (filter != NULL)
> +		if (filter)
>  			/* though it's an empty new sock, the charging may fail
>  			 * if sysctl_optmem_max was changed between creation of
>  			 * original socket and cloning
> @@ -1539,7 +1533,8 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  
>  		if (unlikely(!is_charged || xfrm_sk_clone_policy(newsk))) {
>  			/* It is still raw copy of parent, so invalidate
> -			 * destructor and make plain sk_free() */
> +			 * destructor and make plain sk_free()
> +			 */
>  			newsk->sk_destruct = NULL;
>  			bh_unlock_sock(newsk);
>  			sk_free(newsk);
> @@ -1551,15 +1546,13 @@ struct sock *sk_clone_lock(const struct sock *sk, const gfp_t priority)
>  		newsk->sk_priority = 0;
>  		newsk->sk_incoming_cpu = raw_smp_processor_id();
>  		atomic64_set(&newsk->sk_cookie, 0);
> -		/*
> -		 * Before updating sk_refcnt, we must commit prior changes to memory
> +		/* Before updating sk_refcnt, we must commit prior changes to memory
>  		 * (Documentation/RCU/rculist_nulls.txt for details)
>  		 */
>  		smp_wmb();
>  		atomic_set(&newsk->sk_refcnt, 2);
>  
> -		/*
> -		 * Increment the counter in the same struct proto as the master
> +		/* Increment the counter in the same struct proto as the master
>  		 * sock (sk_refcnt_debug_inc uses newsk->sk_prot->socks, that
>  		 * is the same as sk->sk_prot->socks, as this field was copied
>  		 * with memcpy).
> @@ -1608,30 +1601,23 @@ void sk_setup_caps(struct sock *sk, struct dst_entry *dst)
>  }
>  EXPORT_SYMBOL_GPL(sk_setup_caps);
>  
> -/*
> - *	Simple resource managers for sockets.
> - */
> -
> +/* Simple resource managers for sockets. */
>  
> -/*
> - * Write buffer destructor automatically called from kfree_skb.
> - */
> +/* Write buffer destructor automatically called from kfree_skb. */
>  void sock_wfree(struct sk_buff *skb)
>  {
>  	struct sock *sk = skb->sk;
>  	unsigned int len = skb->truesize;
>  
>  	if (!sock_flag(sk, SOCK_USE_WRITE_QUEUE)) {
> -		/*
> -		 * Keep a reference on sk_wmem_alloc, this will be released
> +		/* Keep a reference on sk_wmem_alloc, this will be released
>  		 * after sk_write_space() call
>  		 */
>  		atomic_sub(len - 1, &sk->sk_wmem_alloc);
>  		sk->sk_write_space(sk);
>  		len = 1;
>  	}
> -	/*
> -	 * if sk_wmem_alloc reaches 0, we must finish what sk_free()
> +	/* if sk_wmem_alloc reaches 0, we must finish what sk_free()
>  	 * could not do because of in-flight packets
>  	 */
>  	if (atomic_sub_and_test(len, &sk->sk_wmem_alloc))
> @@ -1658,9 +1644,7 @@ void skb_orphan_partial(struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(skb_orphan_partial);
>  
> -/*
> - * Read buffer destructor automatically called from kfree_skb.
> - */
> +/* Read buffer destructor automatically called from kfree_skb. */
>  void sock_rfree(struct sk_buff *skb)
>  {
>  	struct sock *sk = skb->sk;
> @@ -1671,8 +1655,7 @@ void sock_rfree(struct sk_buff *skb)
>  }
>  EXPORT_SYMBOL(sock_rfree);
>  
> -/*
> - * Buffer destructor for skbs that are not used directly in read or write
> +/* Buffer destructor for skbs that are not used directly in read or write
>   * path, e.g. for error handler skbs. Automatically called from kfree_skb.
>   */
>  void sock_efree(struct sk_buff *skb)
> @@ -1703,14 +1686,13 @@ unsigned long sock_i_ino(struct sock *sk)
>  }
>  EXPORT_SYMBOL(sock_i_ino);
>  
> -/*
> - * Allocate a skb from the socket's send buffer.
> - */
> +/* Allocate a skb from the socket's send buffer. */
>  struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
>  			     gfp_t priority)
>  {
>  	if (force || atomic_read(&sk->sk_wmem_alloc) < sk->sk_sndbuf) {
>  		struct sk_buff *skb = alloc_skb(size, priority);
> +
>  		if (skb) {
>  			skb_set_owner_w(skb, sk);
>  			return skb;
> @@ -1720,9 +1702,7 @@ struct sk_buff *sock_wmalloc(struct sock *sk, unsigned long size, int force,
>  }
>  EXPORT_SYMBOL(sock_wmalloc);
>  
> -/*
> - * Allocate a memory block from the socket's option memory buffer.
> - */
> +/* Allocate a memory block from the socket's option memory buffer. */
>  void *sock_kmalloc(struct sock *sk, int size, gfp_t priority)
>  {
>  	if ((unsigned int)size <= sysctl_optmem_max &&
> @@ -1770,7 +1750,7 @@ void sock_kzfree_s(struct sock *sk, void *mem, int size)
>  EXPORT_SYMBOL(sock_kzfree_s);
>  
>  /* It is almost wait_for_tcp_memory minus release_sock/lock_sock.
> -   I think, these locks should be removed for datagram sockets.
> + * I think, these locks should be removed for datagram sockets.
>   */
>  static long sock_wait_for_wmem(struct sock *sk, long timeo)
>  {
> @@ -1796,10 +1776,7 @@ static long sock_wait_for_wmem(struct sock *sk, long timeo)
>  	return timeo;
>  }
>  
> -
> -/*
> - *	Generic send/receive buffer handlers
> - */
> +/* Generic send/receive buffer handlers */
>  
>  struct sk_buff *sock_alloc_send_pskb(struct sock *sk, unsigned long header_len,
>  				     unsigned long data_len, int noblock,
> @@ -1915,7 +1892,7 @@ static void __lock_sock(struct sock *sk)
>  
>  	for (;;) {
>  		prepare_to_wait_exclusive(&sk->sk_lock.wq, &wait,
> -					TASK_UNINTERRUPTIBLE);
> +					  TASK_UNINTERRUPTIBLE);
>  		spin_unlock_bh(&sk->sk_lock.slock);
>  		schedule();
>  		spin_lock_bh(&sk->sk_lock.slock);
> @@ -1932,7 +1909,8 @@ static void __release_sock(struct sock *sk)
>  	struct sk_buff *skb = sk->sk_backlog.head;
>  
>  	do {
> -		sk->sk_backlog.head = sk->sk_backlog.tail = NULL;
> +		sk->sk_backlog.head = NULL;
> +		sk->sk_backlog.tail = NULL;
>  		bh_unlock_sock(sk);
>  
>  		do {
> @@ -1943,8 +1921,7 @@ static void __release_sock(struct sock *sk)
>  			skb->next = NULL;
>  			sk_backlog_rcv(sk, skb);
>  
> -			/*
> -			 * We are in process context here with softirqs
> +			/* We are in process context here with softirqs
>  			 * disabled, use cond_resched_softirq() to preempt.
>  			 * This is safe to do because we've taken the backlog
>  			 * queue private:
> @@ -1952,13 +1929,12 @@ static void __release_sock(struct sock *sk)
>  			cond_resched_softirq();
>  
>  			skb = next;
> -		} while (skb != NULL);
> +		} while (skb);
>  
>  		bh_lock_sock(sk);
>  	} while ((skb = sk->sk_backlog.head) != NULL);
>  
> -	/*
> -	 * Doing the zeroing here guarantee we can not loop forever
> +	/* Doing the zeroing here guarantee we can not loop forever
>  	 * while a wild producer attempts to flood us.
>  	 */
>  	sk->sk_backlog.len = 0;
> @@ -2012,19 +1988,19 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
>  
>  	/* Under limit. */
>  	if (parent_status == UNDER_LIMIT &&
> -			allocated <= sk_prot_mem_limits(sk, 0)) {
> +	    allocated <= sk_prot_mem_limits(sk, 0)) {
>  		sk_leave_memory_pressure(sk);
>  		return 1;
>  	}
>  
>  	/* Under pressure. (we or our parents) */
>  	if ((parent_status > SOFT_LIMIT) ||
> -			allocated > sk_prot_mem_limits(sk, 1))
> +	    allocated > sk_prot_mem_limits(sk, 1))
>  		sk_enter_memory_pressure(sk);
>  
>  	/* Over hard limit (we or our parents) */
>  	if ((parent_status == OVER_LIMIT) ||
> -			(allocated > sk_prot_mem_limits(sk, 2)))
> +	    (allocated > sk_prot_mem_limits(sk, 2)))
>  		goto suppress_allocation;
>  
>  	/* guarantee minimum buffer size under pressure */
> @@ -2038,7 +2014,7 @@ int __sk_mem_schedule(struct sock *sk, int size, int kind)
>  				return 1;
>  		} else if (atomic_read(&sk->sk_wmem_alloc) <
>  			   prot->sysctl_wmem[0])
> -				return 1;
> +			return 1;
>  	}
>  
>  	if (sk_has_memory_pressure(sk)) {
> @@ -2094,9 +2070,7 @@ void __sk_mem_reclaim(struct sock *sk, int amount)
>  }
>  EXPORT_SYMBOL(__sk_mem_reclaim);
>  
> -
> -/*
> - * Set of default routines for initialising struct proto_ops when
> +/* Set of default routines for initialising struct proto_ops when
>   * the protocol does not support a particular function. In certain
>   * cases where it makes no sense for a protocol to have a "do nothing"
>   * function, some default processing is provided.
> @@ -2159,14 +2133,14 @@ int sock_no_shutdown(struct socket *sock, int how)
>  EXPORT_SYMBOL(sock_no_shutdown);
>  
>  int sock_no_setsockopt(struct socket *sock, int level, int optname,
> -		    char __user *optval, unsigned int optlen)
> +		       char __user *optval, unsigned int optlen)
>  {
>  	return -EOPNOTSUPP;
>  }
>  EXPORT_SYMBOL(sock_no_setsockopt);
>  
>  int sock_no_getsockopt(struct socket *sock, int level, int optname,
> -		    char __user *optval, int __user *optlen)
> +		       char __user *optval, int __user *optlen)
>  {
>  	return -EOPNOTSUPP;
>  }
> @@ -2185,19 +2159,22 @@ int sock_no_recvmsg(struct socket *sock, struct msghdr *m, size_t len,
>  }
>  EXPORT_SYMBOL(sock_no_recvmsg);
>  
> -int sock_no_mmap(struct file *file, struct socket *sock, struct vm_area_struct *vma)
> +int sock_no_mmap(struct file *file, struct socket *sock,
> +		 struct vm_area_struct *vma)
>  {
>  	/* Mirror missing mmap method error code */
>  	return -ENODEV;
>  }
>  EXPORT_SYMBOL(sock_no_mmap);
>  
> -ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset, size_t size, int flags)
> +ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset,
> +			 size_t size, int flags)
>  {
>  	ssize_t res;
>  	struct msghdr msg = {.msg_flags = flags};
>  	struct kvec iov;
>  	char *kaddr = kmap(page);
> +
>  	iov.iov_base = kaddr + offset;
>  	iov.iov_len = size;
>  	res = kernel_sendmsg(sock, &msg, &iov, 1, size);
> @@ -2206,9 +2183,7 @@ ssize_t sock_no_sendpage(struct socket *sock, struct page *page, int offset, siz
>  }
>  EXPORT_SYMBOL(sock_no_sendpage);
>  
> -/*
> - *	Default Socket Callbacks
> - */
> +/* Default Socket Callbacks */
>  
>  static void sock_def_wakeup(struct sock *sk)
>  {
> @@ -2281,7 +2256,7 @@ void sk_send_sigurg(struct sock *sk)
>  }
>  EXPORT_SYMBOL(sk_send_sigurg);
>  
> -void sk_reset_timer(struct sock *sk, struct timer_list* timer,
> +void sk_reset_timer(struct sock *sk, struct timer_list *timer,
>  		    unsigned long expires)
>  {
>  	if (!mod_timer(timer, expires))
> @@ -2289,7 +2264,7 @@ void sk_reset_timer(struct sock *sk, struct timer_list* timer,
>  }
>  EXPORT_SYMBOL(sk_reset_timer);
>  
> -void sk_stop_timer(struct sock *sk, struct timer_list* timer)
> +void sk_stop_timer(struct sock *sk, struct timer_list *timer)
>  {
>  	if (del_timer(timer))
>  		__sock_put(sk);
> @@ -2302,59 +2277,59 @@ void sock_init_data(struct socket *sock, struct sock *sk)
>  	skb_queue_head_init(&sk->sk_write_queue);
>  	skb_queue_head_init(&sk->sk_error_queue);
>  
> -	sk->sk_send_head	=	NULL;
> +	sk->sk_send_head = NULL;
>  
>  	init_timer(&sk->sk_timer);
>  
> -	sk->sk_allocation	=	GFP_KERNEL;
> -	sk->sk_rcvbuf		=	sysctl_rmem_default;
> -	sk->sk_sndbuf		=	sysctl_wmem_default;
> -	sk->sk_state		=	TCP_CLOSE;
> +	sk->sk_allocation = GFP_KERNEL;
> +	sk->sk_rcvbuf = sysctl_rmem_default;
> +	sk->sk_sndbuf = sysctl_wmem_default;
> +	sk->sk_state = TCP_CLOSE;
>  	sk_set_socket(sk, sock);
>  
>  	sock_set_flag(sk, SOCK_ZAPPED);
>  
>  	if (sock) {
> -		sk->sk_type	=	sock->type;
> -		sk->sk_wq	=	sock->wq;
> -		sock->sk	=	sk;
> -	} else
> -		sk->sk_wq	=	NULL;
> +		sk->sk_type = sock->type;
> +		sk->sk_wq = sock->wq;
> +		sock->sk = sk;
> +	} else {
> +		sk->sk_wq = NULL;
> +	}
>  
>  	spin_lock_init(&sk->sk_dst_lock);
>  	rwlock_init(&sk->sk_callback_lock);
>  	lockdep_set_class_and_name(&sk->sk_callback_lock,
> -			af_callback_keys + sk->sk_family,
> -			af_family_clock_key_strings[sk->sk_family]);
> -
> -	sk->sk_state_change	=	sock_def_wakeup;
> -	sk->sk_data_ready	=	sock_def_readable;
> -	sk->sk_write_space	=	sock_def_write_space;
> -	sk->sk_error_report	=	sock_def_error_report;
> -	sk->sk_destruct		=	sock_def_destruct;
> -
> -	sk->sk_frag.page	=	NULL;
> -	sk->sk_frag.offset	=	0;
> -	sk->sk_peek_off		=	-1;
> -
> -	sk->sk_peer_pid 	=	NULL;
> -	sk->sk_peer_cred	=	NULL;
> -	sk->sk_write_pending	=	0;
> -	sk->sk_rcvlowat		=	1;
> -	sk->sk_rcvtimeo		=	MAX_SCHEDULE_TIMEOUT;
> -	sk->sk_sndtimeo		=	MAX_SCHEDULE_TIMEOUT;
> +				   af_callback_keys + sk->sk_family,
> +				   af_family_clock_key_strings[sk->sk_family]);
> +
> +	sk->sk_state_change = sock_def_wakeup;
> +	sk->sk_data_ready = sock_def_readable;
> +	sk->sk_write_space = sock_def_write_space;
> +	sk->sk_error_report = sock_def_error_report;
> +	sk->sk_destruct	 = sock_def_destruct;
> +
> +	sk->sk_frag.page = NULL;
> +	sk->sk_frag.offset = 0;
> +	sk->sk_peek_off = -1;
> +
> +	sk->sk_peer_pid = NULL;
> +	sk->sk_peer_cred = NULL;
> +	sk->sk_write_pending = 0;
> +	sk->sk_rcvlowat = 1;
> +	sk->sk_rcvtimeo = MAX_SCHEDULE_TIMEOUT;
> +	sk->sk_sndtimeo = MAX_SCHEDULE_TIMEOUT;
>  
>  	sk->sk_stamp = ktime_set(-1L, 0);
>  
>  #ifdef CONFIG_NET_RX_BUSY_POLL
> -	sk->sk_napi_id		=	0;
> -	sk->sk_ll_usec		=	sysctl_net_busy_read;
> +	sk->sk_napi_id = 0;
> +	sk->sk_ll_usec = sysctl_net_busy_read;
>  #endif
>  
>  	sk->sk_max_pacing_rate = ~0U;
>  	sk->sk_pacing_rate = ~0U;
> -	/*
> -	 * Before updating sk_refcnt, we must commit prior changes to memory
> +	/* Before updating sk_refcnt, we must commit prior changes to memory
>  	 * (Documentation/RCU/rculist_nulls.txt for details)
>  	 */
>  	smp_wmb();
> @@ -2371,9 +2346,8 @@ void lock_sock_nested(struct sock *sk, int subclass)
>  		__lock_sock(sk);
>  	sk->sk_lock.owned = 1;
>  	spin_unlock(&sk->sk_lock.slock);
> -	/*
> -	 * The sk_lock has mutex_lock() semantics here:
> -	 */
> +
> +	/* The sk_lock has mutex_lock() semantics here: */
>  	mutex_acquire(&sk->sk_lock.dep_map, subclass, 0, _RET_IP_);
>  	local_bh_enable();
>  }
> @@ -2381,9 +2355,7 @@ EXPORT_SYMBOL(lock_sock_nested);
>  
>  void release_sock(struct sock *sk)
>  {
> -	/*
> -	 * The sk_lock has mutex_unlock() semantics:
> -	 */
> +	/* The sk_lock has mutex_unlock() semantics: */
>  	mutex_release(&sk->sk_lock.dep_map, 1, _RET_IP_);
>  
>  	spin_lock_bh(&sk->sk_lock.slock);
> @@ -2419,17 +2391,13 @@ bool lock_sock_fast(struct sock *sk)
>  	spin_lock_bh(&sk->sk_lock.slock);
>  
>  	if (!sk->sk_lock.owned)
> -		/*
> -		 * Note : We must disable BH
> -		 */
> +		/* Note : We must disable BH */
>  		return false;
>  
>  	__lock_sock(sk);
>  	sk->sk_lock.owned = 1;
>  	spin_unlock(&sk->sk_lock.slock);
> -	/*
> -	 * The sk_lock has mutex_lock() semantics here:
> -	 */
> +	/* The sk_lock has mutex_lock() semantics here: */
>  	mutex_acquire(&sk->sk_lock.dep_map, 0, 0, _RET_IP_);
>  	local_bh_enable();
>  	return true;
> @@ -2439,6 +2407,7 @@ EXPORT_SYMBOL(lock_sock_fast);
>  int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
>  {
>  	struct timeval tv;
> +
>  	if (!sock_flag(sk, SOCK_TIMESTAMP))
>  		sock_enable_timestamp(sk, SOCK_TIMESTAMP);
>  	tv = ktime_to_timeval(sk->sk_stamp);
> @@ -2455,6 +2424,7 @@ EXPORT_SYMBOL(sock_get_timestamp);
>  int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
>  {
>  	struct timespec ts;
> +
>  	if (!sock_flag(sk, SOCK_TIMESTAMP))
>  		sock_enable_timestamp(sk, SOCK_TIMESTAMP);
>  	ts = ktime_to_timespec(sk->sk_stamp);
> @@ -2474,8 +2444,7 @@ void sock_enable_timestamp(struct sock *sk, int flag)
>  		unsigned long previous_flags = sk->sk_flags;
>  
>  		sock_set_flag(sk, flag);
> -		/*
> -		 * we just set one of the two flags which require net
> +		/* we just set one of the two flags which require net
>  		 * time stamping, but time stamping might have been on
>  		 * already because of the other one
>  		 */
> @@ -2493,7 +2462,7 @@ int sock_recv_errqueue(struct sock *sk, struct msghdr *msg, int len,
>  
>  	err = -EAGAIN;
>  	skb = sock_dequeue_err_skb(sk);
> -	if (skb == NULL)
> +	if (!skb)
>  		goto out;
>  
>  	copied = skb->len;
> @@ -2520,8 +2489,7 @@ out:
>  }
>  EXPORT_SYMBOL(sock_recv_errqueue);
>  
> -/*
> - *	Get a socket option on an socket.
> +/*	Get a socket option on an socket.
>   *
>   *	FIX: POSIX 1003.1g is very ambiguous here. It states that
>   *	asynchronous errors should be reported by getsockopt. We assume
> @@ -2542,7 +2510,7 @@ int compat_sock_common_getsockopt(struct socket *sock, int level, int optname,
>  {
>  	struct sock *sk = sock->sk;
>  
> -	if (sk->sk_prot->compat_getsockopt != NULL)
> +	if (sk->sk_prot->compat_getsockopt)
>  		return sk->sk_prot->compat_getsockopt(sk, level, optname,
>  						      optval, optlen);
>  	return sk->sk_prot->getsockopt(sk, level, optname, optval, optlen);
> @@ -2565,9 +2533,7 @@ int sock_common_recvmsg(struct socket *sock, struct msghdr *msg, size_t size,
>  }
>  EXPORT_SYMBOL(sock_common_recvmsg);
>  
> -/*
> - *	Set socket options on an inet socket.
> - */
> +/* Set socket options on an inet socket. */
>  int sock_common_setsockopt(struct socket *sock, int level, int optname,
>  			   char __user *optval, unsigned int optlen)
>  {
> @@ -2583,7 +2549,7 @@ int compat_sock_common_setsockopt(struct socket *sock, int level, int optname,
>  {
>  	struct sock *sk = sock->sk;
>  
> -	if (sk->sk_prot->compat_setsockopt != NULL)
> +	if (sk->sk_prot->compat_setsockopt)
>  		return sk->sk_prot->compat_setsockopt(sk, level, optname,
>  						      optval, optlen);
>  	return sk->sk_prot->setsockopt(sk, level, optname, optval, optlen);
> @@ -2596,8 +2562,7 @@ void sk_common_release(struct sock *sk)
>  	if (sk->sk_prot->destroy)
>  		sk->sk_prot->destroy(sk);
>  
> -	/*
> -	 * Observation: when sock_common_release is called, processes have
> +	/* Observation: when sock_common_release is called, processes have
>  	 * no access to socket. But net still has.
>  	 * Step one, detach it from networking:
>  	 *
> @@ -2606,8 +2571,7 @@ void sk_common_release(struct sock *sk)
>  
>  	sk->sk_prot->unhash(sk);
>  
> -	/*
> -	 * In this point socket cannot receive new packets, but it is possible
> +	/* In this point socket cannot receive new packets, but it is possible
>  	 * that some packets are in flight because some CPU runs receiver and
>  	 * did hash table lookup before we unhashed socket. They will achieve
>  	 * receive queue and will be purged by socket destructor.
> @@ -2740,10 +2704,8 @@ static void req_prot_cleanup(struct request_sock_ops *rsk_prot)
>  		return;
>  	kfree(rsk_prot->slab_name);
>  	rsk_prot->slab_name = NULL;
> -	if (rsk_prot->slab) {
> -		kmem_cache_destroy(rsk_prot->slab);
> -		rsk_prot->slab = NULL;
> -	}
> +	kmem_cache_destroy(rsk_prot->slab);
> +	rsk_prot->slab = NULL;
>  }
>  
>  static int req_prot_init(const struct proto *prot)
> @@ -2777,7 +2739,7 @@ int proto_register(struct proto *prot, int alloc_slab)
>  					SLAB_HWCACHE_ALIGN | prot->slab_flags,
>  					NULL);
>  
> -		if (prot->slab == NULL) {
> +		if (!prot->slab) {
>  			pr_crit("%s: Can't create sock SLAB cache!\n",
>  				prot->name);
>  			goto out;
> @@ -2786,10 +2748,10 @@ int proto_register(struct proto *prot, int alloc_slab)
>  		if (req_prot_init(prot))
>  			goto out_free_request_sock_slab;
>  
> -		if (prot->twsk_prot != NULL) {
> +		if (prot->twsk_prot) {
>  			prot->twsk_prot->twsk_slab_name = kasprintf(GFP_KERNEL, "tw_sock_%s", prot->name);
>  
> -			if (prot->twsk_prot->twsk_slab_name == NULL)
> +			if (!prot->twsk_prot->twsk_slab_name)
>  				goto out_free_request_sock_slab;
>  
>  			prot->twsk_prot->twsk_slab =
> @@ -2798,7 +2760,7 @@ int proto_register(struct proto *prot, int alloc_slab)
>  						  0,
>  						  prot->slab_flags,
>  						  NULL);
> -			if (prot->twsk_prot->twsk_slab == NULL)
> +			if (!prot->twsk_prot->twsk_slab)
>  				goto out_free_timewait_sock_slab_name;
>  		}
>  	}
> @@ -2828,14 +2790,12 @@ void proto_unregister(struct proto *prot)
>  	list_del(&prot->node);
>  	mutex_unlock(&proto_list_mutex);
>  
> -	if (prot->slab != NULL) {
> -		kmem_cache_destroy(prot->slab);
> -		prot->slab = NULL;
> -	}
> +	kmem_cache_destroy(prot->slab);
> +	prot->slab = NULL;
>  
>  	req_prot_cleanup(prot->rsk_prot);
>  
> -	if (prot->twsk_prot != NULL && prot->twsk_prot->twsk_slab != NULL) {
> +	if (prot->twsk_prot && prot->twsk_prot->twsk_slab) {
>  		kmem_cache_destroy(prot->twsk_prot->twsk_slab);
>  		kfree(prot->twsk_prot->twsk_slab_name);
>  		prot->twsk_prot->twsk_slab = NULL;
> @@ -2864,22 +2824,21 @@ static void proto_seq_stop(struct seq_file *seq, void *v)
>  
>  static char proto_method_implemented(const void *method)
>  {
> -	return method == NULL ? 'n' : 'y';
> +	return !method ? 'n' : 'y';
>  }
>  static long sock_prot_memory_allocated(struct proto *proto)
>  {
> -	return proto->memory_allocated != NULL ? proto_memory_allocated(proto) : -1L;
> +	return proto->memory_allocated ? proto_memory_allocated(proto) : -1L;
>  }
>  
>  static char *sock_prot_memory_pressure(struct proto *proto)
>  {
> -	return proto->memory_pressure != NULL ?
> +	return proto->memory_pressure ?
>  	proto_memory_pressure(proto) ? "yes" : "no" : "NI";
>  }
>  
>  static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
>  {
> -
>  	seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
>  			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
>  		   proto->name,
> @@ -2888,7 +2847,7 @@ static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
>  		   sock_prot_memory_allocated(proto),
>  		   sock_prot_memory_pressure(proto),
>  		   proto->max_header,
> -		   proto->slab == NULL ? "no" : "yes",
> +		   !proto->slab ? "no" : "yes",
>  		   module_name(proto->owner),
>  		   proto_method_implemented(proto->close),
>  		   proto_method_implemented(proto->connect),
> @@ -2963,8 +2922,7 @@ static __net_exit void proto_exit_net(struct net *net)
>  	remove_proc_entry("protocols", net->proc_net);
>  }
>  
> -
> -static __net_initdata struct pernet_operations proto_net_ops = {
> +static struct pernet_operations proto_net_ops __net_initdata = {
>  	.init = proto_init_net,
>  	.exit = proto_exit_net,
>  };
