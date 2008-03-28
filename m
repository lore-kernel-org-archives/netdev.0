From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH net-2.6.26 4/5][SOCK]: Drop inuse pcounter from struct
 proto (v2).
Date: Fri, 28 Mar 2008 18:20:02 +0100
Message-ID: <47ED28C2.4060303@cosmosbay.com>
References: <47ECE67A.2030503@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.orange.fr ([80.12.242.97]:61703 "EHLO smtp23.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753911AbYC1RuH convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 13:50:07 -0400
Received: from smtp23.orange.fr (mwinf2348 [10.232.4.148])
	by mwinf2315.orange.fr (SMTP Server) with ESMTP id 3E2EB1C1ABE0
	for <netdev@vger.kernel.org>; Fri, 28 Mar 2008 18:20:40 +0100 (CET)
In-Reply-To: <47ECE67A.2030503@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov a =E9crit :
> An uppercut - do not use the pcounter on struct proto.
>
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
>
>  =20
Thanks a lot Pavel for this excellent work.

Acked-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
>  include/net/sock.h  |    6 ------
>  net/dccp/ipv4.c     |    3 ---
>  net/dccp/ipv6.c     |    3 ---
>  net/ipv4/raw.c      |    3 ---
>  net/ipv4/tcp_ipv4.c |    3 ---
>  net/ipv4/udp.c      |    3 ---
>  net/ipv4/udplite.c  |    3 ---
>  net/ipv6/raw.c      |    3 ---
>  net/ipv6/tcp_ipv6.c |    3 ---
>  net/ipv6/udp.c      |    3 ---
>  net/ipv6/udplite.c  |    3 ---
>  net/sctp/socket.c   |    5 -----
>  12 files changed, 0 insertions(+), 41 deletions(-)
>
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 1f42942..2a3344f 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -47,7 +47,6 @@
>  #include <linux/module.h>
>  #include <linux/lockdep.h>
>  #include <linux/netdevice.h>
> -#include <linux/pcounter.h>
>  #include <linux/skbuff.h>	/* struct sk_buff */
>  #include <linux/mm.h>
>  #include <linux/security.h>
> @@ -563,7 +562,6 @@ struct proto {
>  	/* Keeping track of sockets in use */
>  #ifdef CONFIG_PROC_FS
>  	unsigned int		inuse_idx;
> -	struct pcounter		inuse;
>  #endif
> =20
>  	/* Memory pressure */
> @@ -636,14 +634,10 @@ static inline void sk_refcnt_debug_release(cons=
t struct sock *sk)
> =20
> =20
>  #ifdef CONFIG_PROC_FS
> -# define DEFINE_PROTO_INUSE(NAME) DEFINE_PCOUNTER(NAME)
> -# define REF_PROTO_INUSE(NAME) PCOUNTER_MEMBER_INITIALIZER(NAME, .in=
use)
>  /* Called with local bh disabled */
>  extern void sock_prot_inuse_add(struct proto *prot, int inc);
>  extern int sock_prot_inuse_get(struct proto *proto);
>  #else
> -# define DEFINE_PROTO_INUSE(NAME)
> -# define REF_PROTO_INUSE(NAME)
>  static void inline sock_prot_inuse_add(struct proto *prot, int inc)
>  {
>  }
> diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
> index 4ca8b0c..7d62f7e 100644
> --- a/net/dccp/ipv4.c
> +++ b/net/dccp/ipv4.c
> @@ -915,8 +915,6 @@ static struct timewait_sock_ops dccp_timewait_soc=
k_ops =3D {
>  	.twsk_obj_size	=3D sizeof(struct inet_timewait_sock),
>  };
> =20
> -DEFINE_PROTO_INUSE(dccp_v4)
> -
>  static struct proto dccp_v4_prot =3D {
>  	.name			=3D "DCCP",
>  	.owner			=3D THIS_MODULE,
> @@ -946,7 +944,6 @@ static struct proto dccp_v4_prot =3D {
>  	.compat_setsockopt	=3D compat_dccp_setsockopt,
>  	.compat_getsockopt	=3D compat_dccp_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(dccp_v4)
>  };
> =20
>  static struct net_protocol dccp_v4_protocol =3D {
> diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
> index 2fec1af..ea3f326 100644
> --- a/net/dccp/ipv6.c
> +++ b/net/dccp/ipv6.c
> @@ -1100,8 +1100,6 @@ static struct timewait_sock_ops dccp6_timewait_=
sock_ops =3D {
>  	.twsk_obj_size	=3D sizeof(struct dccp6_timewait_sock),
>  };
> =20
> -DEFINE_PROTO_INUSE(dccp_v6)
> -
>  static struct proto dccp_v6_prot =3D {
>  	.name		   =3D "DCCPv6",
>  	.owner		   =3D THIS_MODULE,
> @@ -1131,7 +1129,6 @@ static struct proto dccp_v6_prot =3D {
>  	.compat_setsockopt =3D compat_dccp_setsockopt,
>  	.compat_getsockopt =3D compat_dccp_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(dccp_v6)
>  };
> =20
>  static struct inet6_protocol dccp_v6_protocol =3D {
> diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
> index d965f0a..3492050 100644
> --- a/net/ipv4/raw.c
> +++ b/net/ipv4/raw.c
> @@ -818,8 +818,6 @@ static int raw_ioctl(struct sock *sk, int cmd, un=
signed long arg)
>  	}
>  }
> =20
> -DEFINE_PROTO_INUSE(raw)
> -
>  struct proto raw_prot =3D {
>  	.name		   =3D "RAW",
>  	.owner		   =3D THIS_MODULE,
> @@ -842,7 +840,6 @@ struct proto raw_prot =3D {
>  	.compat_setsockopt =3D compat_raw_setsockopt,
>  	.compat_getsockopt =3D compat_raw_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(raw)
>  };
> =20
>  #ifdef CONFIG_PROC_FS
> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 2a5881c..ef141b8 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -2451,8 +2451,6 @@ void tcp4_proc_exit(void)
>  }
>  #endif /* CONFIG_PROC_FS */
> =20
> -DEFINE_PROTO_INUSE(tcp)
> -
>  struct proto tcp_prot =3D {
>  	.name			=3D "TCP",
>  	.owner			=3D THIS_MODULE,
> @@ -2488,7 +2486,6 @@ struct proto tcp_prot =3D {
>  	.compat_setsockopt	=3D compat_tcp_setsockopt,
>  	.compat_getsockopt	=3D compat_tcp_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(tcp)
>  };
> =20
>  void __init tcp_v4_init(void)
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 80007c7..0255f37 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1467,8 +1467,6 @@ unsigned int udp_poll(struct file *file, struct=
 socket *sock, poll_table *wait)
> =20
>  }
> =20
> -DEFINE_PROTO_INUSE(udp)
> -
>  struct proto udp_prot =3D {
>  	.name		   =3D "UDP",
>  	.owner		   =3D THIS_MODULE,
> @@ -1496,7 +1494,6 @@ struct proto udp_prot =3D {
>  	.compat_setsockopt =3D compat_udp_setsockopt,
>  	.compat_getsockopt =3D compat_udp_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(udp)
>  };
> =20
>  /* -----------------------------------------------------------------=
------- */
> diff --git a/net/ipv4/udplite.c b/net/ipv4/udplite.c
> index 53f3ed4..7c1e027 100644
> --- a/net/ipv4/udplite.c
> +++ b/net/ipv4/udplite.c
> @@ -34,8 +34,6 @@ static	struct net_protocol udplite_protocol =3D {
>  	.netns_ok	=3D 1,
>  };
> =20
> -DEFINE_PROTO_INUSE(udplite)
> -
>  struct proto 	udplite_prot =3D {
>  	.name		   =3D "UDP-Lite",
>  	.owner		   =3D THIS_MODULE,
> @@ -60,7 +58,6 @@ struct proto 	udplite_prot =3D {
>  	.compat_setsockopt =3D compat_udp_setsockopt,
>  	.compat_getsockopt =3D compat_udp_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(udplite)
>  };
> =20
>  static struct inet_protosw udplite4_protosw =3D {
> diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
> index 830da46..c1e495f 100644
> --- a/net/ipv6/raw.c
> +++ b/net/ipv6/raw.c
> @@ -1171,8 +1171,6 @@ static int rawv6_init_sk(struct sock *sk)
>  	return(0);
>  }
> =20
> -DEFINE_PROTO_INUSE(rawv6)
> -
>  struct proto rawv6_prot =3D {
>  	.name		   =3D "RAWv6",
>  	.owner		   =3D THIS_MODULE,
> @@ -1196,7 +1194,6 @@ struct proto rawv6_prot =3D {
>  	.compat_setsockopt =3D compat_rawv6_setsockopt,
>  	.compat_getsockopt =3D compat_rawv6_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(rawv6)
>  };
> =20
>  #ifdef CONFIG_PROC_FS
> diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
> index 323c7e0..6d851c3 100644
> --- a/net/ipv6/tcp_ipv6.c
> +++ b/net/ipv6/tcp_ipv6.c
> @@ -2140,8 +2140,6 @@ void tcp6_proc_exit(struct net *net)
>  }
>  #endif
> =20
> -DEFINE_PROTO_INUSE(tcpv6)
> -
>  struct proto tcpv6_prot =3D {
>  	.name			=3D "TCPv6",
>  	.owner			=3D THIS_MODULE,
> @@ -2177,7 +2175,6 @@ struct proto tcpv6_prot =3D {
>  	.compat_setsockopt	=3D compat_tcp_setsockopt,
>  	.compat_getsockopt	=3D compat_tcp_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(tcpv6)
>  };
> =20
>  static struct inet6_protocol tcpv6_protocol =3D {
> diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
> index aacbc82..463ae4d 100644
> --- a/net/ipv6/udp.c
> +++ b/net/ipv6/udp.c
> @@ -999,8 +999,6 @@ void udp6_proc_exit(struct net *net) {
> =20
>  /* -----------------------------------------------------------------=
------- */
> =20
> -DEFINE_PROTO_INUSE(udpv6)
> -
>  struct proto udpv6_prot =3D {
>  	.name		   =3D "UDPv6",
>  	.owner		   =3D THIS_MODULE,
> @@ -1027,7 +1025,6 @@ struct proto udpv6_prot =3D {
>  	.compat_setsockopt =3D compat_udpv6_setsockopt,
>  	.compat_getsockopt =3D compat_udpv6_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(udpv6)
>  };
> =20
>  static struct inet_protosw udpv6_protosw =3D {
> diff --git a/net/ipv6/udplite.c b/net/ipv6/udplite.c
> index 706c5c3..c5f5357 100644
> --- a/net/ipv6/udplite.c
> +++ b/net/ipv6/udplite.c
> @@ -35,8 +35,6 @@ static struct inet6_protocol udplitev6_protocol =3D=
 {
>  	.flags		=3D	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
>  };
> =20
> -DEFINE_PROTO_INUSE(udplitev6)
> -
>  struct proto udplitev6_prot =3D {
>  	.name		   =3D "UDPLITEv6",
>  	.owner		   =3D THIS_MODULE,
> @@ -60,7 +58,6 @@ struct proto udplitev6_prot =3D {
>  	.compat_setsockopt =3D compat_udpv6_setsockopt,
>  	.compat_getsockopt =3D compat_udpv6_getsockopt,
>  #endif
> -	REF_PROTO_INUSE(udplitev6)
>  };
> =20
>  static struct inet_protosw udplite6_protosw =3D {
> diff --git a/net/sctp/socket.c b/net/sctp/socket.c
> index 76c7470..00ebd06 100644
> --- a/net/sctp/socket.c
> +++ b/net/sctp/socket.c
> @@ -6513,8 +6513,6 @@ static void sctp_sock_migrate(struct sock *olds=
k, struct sock *newsk,
>  }
> =20
> =20
> -DEFINE_PROTO_INUSE(sctp)
> -
>  /* This proto struct describes the ULP interface for SCTP.  */
>  struct proto sctp_prot =3D {
>  	.name        =3D	"SCTP",
> @@ -6544,11 +6542,9 @@ struct proto sctp_prot =3D {
>  	.enter_memory_pressure =3D sctp_enter_memory_pressure,
>  	.memory_allocated =3D &sctp_memory_allocated,
>  	.sockets_allocated =3D &sctp_sockets_allocated,
> -	REF_PROTO_INUSE(sctp)
>  };
> =20
>  #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
> -DEFINE_PROTO_INUSE(sctpv6)
> =20
>  struct proto sctpv6_prot =3D {
>  	.name		=3D "SCTPv6",
> @@ -6578,6 +6574,5 @@ struct proto sctpv6_prot =3D {
>  	.enter_memory_pressure =3D sctp_enter_memory_pressure,
>  	.memory_allocated =3D &sctp_memory_allocated,
>  	.sockets_allocated =3D &sctp_sockets_allocated,
> -	REF_PROTO_INUSE(sctpv6)
>  };
>  #endif /* defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) */
>  =20




