From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: Deadlock with icmpv6fuzz
Date: Tue, 20 Jan 2009 21:47:43 +0100
Message-ID: <20090120204743.GA25797@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:48219 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1757016AbZATUsQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 15:48:16 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I can get my box into a deadlock when running "icmpv6fuzz -r 25668",
source code is attached

# CONFIG_CLASSIC_RCU is not set
CONFIG_TREE_RCU=3Dy
# CONFIG_PREEMPT_RCU is not set
CONFIG_RCU_TRACE=3Dy
CONFIG_RCU_FANOUT=3D32
# CONFIG_RCU_FANOUT_EXACT is not set
CONFIG_TREE_RCU_TRACE=3Dy
# CONFIG_PREEMPT_RCU_TRACE is not set
CONFIG_RCU_TORTURE_TEST=3Dm
CONFIG_RCU_CPU_STALL_DETECTOR=3Dy

CONFIG_IPV6=3Dm
CONFIG_IPV6_PRIVACY=3Dy
# CONFIG_IPV6_ROUTER_PREF is not set
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
# CONFIG_IPV6_MIP6 is not set
CONFIG_IPV6_SIT=3Dm
CONFIG_IPV6_NDISC_NODETYPE=3Dy
CONFIG_IPV6_TUNNEL=3Dm
# CONFIG_IPV6_MULTIPLE_TABLES is not set
# CONFIG_IPV6_MROUTE is not set
CONFIG_NF_CONNTRACK_IPV6=3Dm
CONFIG_IP6_NF_MATCH_IPV6HEADER=3Dm

Kernel is current -git

[ 5459.100023] INFO: RCU detected CPU 0 stall (t=3D2500 jiffies)
[ 5459.100023] Pid: 25668, comm: icmpv6fuzz Not tainted 2.6.29-rc2 #92
[ 5459.100023] Call Trace:
[ 5459.100023]  [<c0629676>] ? printk+0x18/0x1a
[ 5459.100023]  [<c016db22>] __rcu_pending+0x62/0x250
[ 5459.100023]  [<c014c55b>] ? trace_hardirqs_off+0xb/0x10
[ 5459.100023]  [<c016dd22>] rcu_pending+0x12/0x40
[ 5459.100023]  [<c0132b8a>] update_process_times+0x2a/0x60
[ 5459.100023]  [<c014a115>] tick_sched_timer+0x55/0xc0
[ 5459.100023]  [<c014a0c0>] ? tick_sched_timer+0x0/0xc0
[ 5459.100023]  [<c01409b0>] __run_hrtimer+0x70/0xe0
[ 5459.100023]  [<c014a0c0>] ? tick_sched_timer+0x0/0xc0
[ 5459.100023]  [<c014118d>] hrtimer_interrupt+0xed/0x190
[ 5459.100023]  [<c010597b>] timer_interrupt+0x3b/0x50
[ 5459.100023]  [<c016ac19>] handle_IRQ_event+0x29/0x60
[ 5459.100023]  [<c016c9a5>] handle_level_irq+0x65/0xe0
[ 5459.100023]  [<c016c940>] ? handle_level_irq+0x0/0xe0
[ 5459.100023]  <IRQ>  [<c014e9b1>] ? trace_hardirqs_on_caller+0x151/0x=
1c0
[ 5459.100023]  [<c0103bac>] ? common_interrupt+0x2c/0x34
[ 5459.100023]  [<c014007b>] ? posix_cpu_clock_get+0xb/0x160
[ 5459.100023]  [<d18a6e87>] ? ipv6_push_exthdr+0x17/0x70 [ipv6]
[ 5459.100023]  [<c0570aaf>] ? skb_store_bits+0x10f/0x200
[ 5459.100023]  [<d18a6f03>] ? ipv6_push_frag_opts+0x23/0x30 [ipv6]
[ 5459.100023]  [<d18858ab>] ? ip6_push_pending_frames+0x21b/0x3e0 [ipv=
6]
[ 5459.100023]  [<d189b01a>] ? rawv6_sendmsg+0xbfa/0xc70 [ipv6]
[ 5459.100023]  [<c05f0494>] ? inet_sendmsg+0x34/0x60
[ 5459.100023]  [<c056a909>] ? sock_sendmsg+0xe9/0x110
[ 5459.100023]  [<c013d800>] ? autoremove_wake_function+0x0/0x50
[ 5459.100023]  [<c018db96>] ? might_fault+0x46/0xa0
[ 5459.100023]  [<c018dbe1>] ? might_fault+0x91/0xa0
[ 5459.100023]  [<c018db96>] ? might_fault+0x46/0xa0
[ 5459.100023]  [<c031aa65>] ? copy_from_user+0x35/0x130
[ 5459.100023]  [<c056ac55>] ? sys_sendto+0xa5/0xd0
[ 5459.100023]  [<c018db96>] ? might_fault+0x46/0xa0
[ 5459.100023]  [<c0568fb0>] ? sock_ioctl+0x0/0x240
[ 5459.100023]  [<c018db96>] ? might_fault+0x46/0xa0
[ 5459.100023]  [<c056b28b>] ? sys_socketcall+0x18b/0x2a0
[ 5459.100023]  [<c0103551>] ? sysenter_do_call+0x12/0x31
[ 5489.100020] INFO: RCU detected CPU 0 stall (t=3D10000 jiffies)
[ 5489.100020] Pid: 25668, comm: icmpv6fuzz Not tainted 2.6.29-rc2 #92
[ 5489.100020] Call Trace:
[ 5489.100020]  [<c0629676>] ? printk+0x18/0x1a
[ 5489.100020]  [<c016db22>] __rcu_pending+0x62/0x250
[ 5489.100020]  [<c014c55b>] ? trace_hardirqs_off+0xb/0x10
[ 5489.100020]  [<c016dd22>] rcu_pending+0x12/0x40
[ 5489.100020]  [<c0132b8a>] update_process_times+0x2a/0x60
[ 5489.100020]  [<c014a115>] tick_sched_timer+0x55/0xc0
[ 5489.100020]  [<c014a0c0>] ? tick_sched_timer+0x0/0xc0
[ 5489.100020]  [<c01409b0>] __run_hrtimer+0x70/0xe0
[ 5489.100020]  [<c014a0c0>] ? tick_sched_timer+0x0/0xc0
[ 5489.100020]  [<c014118d>] hrtimer_interrupt+0xed/0x190
[ 5489.100020]  [<c010597b>] timer_interrupt+0x3b/0x50
[ 5489.100020]  [<c016ac19>] handle_IRQ_event+0x29/0x60
[ 5489.100020]  [<c016c9a5>] handle_level_irq+0x65/0xe0
[ 5489.100020]  [<c016c940>] ? handle_level_irq+0x0/0xe0
[ 5489.100020]  <IRQ>  [<c014e9b1>] ? trace_hardirqs_on_caller+0x151/0x=
1c0
[ 5489.100020]  [<c0103bac>] ? common_interrupt+0x2c/0x34
[ 5489.100020]  [<c014007b>] ? posix_cpu_clock_get+0xb/0x160
[ 5489.100020]  [<d18a6e87>] ? ipv6_push_exthdr+0x17/0x70 [ipv6]
[ 5489.100020]  [<c0570aaf>] ? skb_store_bits+0x10f/0x200
[ 5489.100020]  [<d18a6f03>] ? ipv6_push_frag_opts+0x23/0x30 [ipv6]
[ 5489.100020]  [<d18858ab>] ? ip6_push_pending_frames+0x21b/0x3e0 [ipv=
6]
[ 5489.100020]  [<d189b01a>] ? rawv6_sendmsg+0xbfa/0xc70 [ipv6]
[ 5489.100020]  [<c05f0494>] ? inet_sendmsg+0x34/0x60
[ 5489.100020]  [<c056a909>] ? sock_sendmsg+0xe9/0x110
[ 5489.100020]  [<c013d800>] ? autoremove_wake_function+0x0/0x50
[ 5489.100020]  [<c018db96>] ? might_fault+0x46/0xa0
[ 5489.100020]  [<c018dbe1>] ? might_fault+0x91/0xa0
[ 5489.100020]  [<c018db96>] ? might_fault+0x46/0xa0
[ 5489.100020]  [<c031aa65>] ? copy_from_user+0x35/0x130
[ 5489.100020]  [<c056ac55>] ? sys_sendto+0xa5/0xd0
[ 5489.100020]  [<c018db96>] ? might_fault+0x46/0xa0
[ 5489.100020]  [<c0568fb0>] ? sock_ioctl+0x0/0x240
[ 5489.100020]  [<c018db96>] ? might_fault+0x46/0xa0
[ 5489.100020]  [<c056b28b>] ? sys_socketcall+0x18b/0x2a0
[ 5489.100020]  [<c0103551>] ? sysenter_do_call+0x12/0x31

and so on

(gdb) l*(ipv6_push_exthdr+0x17)
0x4d7 is in ipv6_push_exthdr (net/ipv6/exthdrs.c:700).
695		*proto =3D NEXTHDR_ROUTING;
696	}
697=09
698	static void ipv6_push_exthdr(struct sk_buff *skb, u8 *proto, u8 typ=
e, struct ipv6_opt_hdr *opt)
699	{
700		struct ipv6_opt_hdr *h =3D (struct ipv6_opt_hdr *)skb_push(skb, ip=
v6_optlen(opt));
701=09
702		memcpy(h, opt, ipv6_optlen(opt));
703		h->nexthdr =3D *proto;
704		*proto =3D type;

(gdb) l*(skb_store_bits+0x10f)
0x282f is in skb_store_bits (net/core/skbuff.c:1567).
1562				vaddr =3D kmap_skb_frag(frag);
1563				memcpy(vaddr + frag->page_offset + offset - start,
1564				       from, copy);
1565				kunmap_skb_frag(vaddr);
1566=09
1567				if ((len -=3D copy) =3D=3D 0)
1568					return 0;
1569				offset +=3D copy;
1570				from +=3D copy;
1571			}

(gdb) l*(ipv6_push_frag_opts+0x23)
0x553 is in ipv6_push_frag_opts (net/ipv6/exthdrs.c:730).
725=09
726	void ipv6_push_frag_opts(struct sk_buff *skb, struct ipv6_txoptions=
 *opt, u8 *proto)
727	{
728		if (opt->dst1opt)
729			ipv6_push_exthdr(skb, proto, NEXTHDR_DEST, opt->dst1opt);
730	}
731=09
732	struct ipv6_txoptions *
733	ipv6_dup_options(struct sock *sk, struct ipv6_txoptions *opt)
734	{




Running the same command on a different box with a different config

[11237.306574] skb_under_panic: text:c071d473 len:2361 put:864 head:ca7=
510c0 data:ca750f10 tail:0xca751270 end:0xca751280 dev:<NULL>
[11237.306909] ------------[ cut here ]------------
[11237.307002] kernel BUG at net/core/skbuff.c:147!
[11237.307045] invalid opcode: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
[11237.307045] last sysfs file: /sys/class/vc/vcsa50/dev
[11237.307045] Modules linked in: [last unloaded: rcutorture]
[11237.307045]=20
[11237.307045] Pid: 19951, comm: icmpv6fuzz Not tainted (2.6.29-rc2-000=
21-gd84d31c #216) System Name
[11237.307045] EIP: 0060:[<c06918e1>] EFLAGS: 00010246 CPU: 0
[11237.307045] EIP is at skb_under_panic+0x3f/0x46
[11237.307045] EAX: 00000088 EBX: c098dafb ECX: c012413f EDX: c012476a
[11237.307045] ESI: 00000000 EDI: ca5b5ccc EBP: ca5b5c68 ESP: ca5b5c3c
[11237.307045]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[11237.307045] Process icmpv6fuzz (pid: 19951, ti=3Dca5b5000 task=3Dc2a=
a0000 task.ti=3Dca5b5000)
[11237.307045] Stack:
[11237.307045]  c09d321a c071d473 00000939 00000360 ca7510c0 ca750f10 c=
a751270 ca751280
[11237.307045]  c098dafb cce2e620 c724c0cc ca5b5c74 c0692b30 ca5b5cd3 c=
a5b5c90 c071d473
[11237.307045]  0000003c ca5b5c90 cce2e620 cedc11b4 ca5b5ccc ca5b5ca0 c=
071d4c5 c724c0cc
[11237.307045] Call Trace:
[11237.307045]  [<c071d473>] ? ipv6_push_exthdr+0x26/0x55
[11237.307045]  [<c0692b30>] ? skb_push+0x2c/0x35
[11237.307045]  [<c071d473>] ? ipv6_push_exthdr+0x26/0x55
[11237.307045]  [<c071d4c5>] ? ipv6_push_frag_opts+0x23/0x29
[11237.307045]  [<c0701a8a>] ? ip6_push_pending_frames+0x1b2/0x39b
[11237.307045]  [<c07145b1>] ? rawv6_sendmsg+0xa84/0xb17
[11237.307045]  [<c013ec6d>] ? put_lock_stats+0xd/0x21
[11237.307045]  [<c013ec6d>] ? put_lock_stats+0xd/0x21
[11237.307045]  [<c013ed20>] ? lock_release_holdtime+0x9f/0xa7
[11237.307045]  [<c06db84a>] ? inet_sendmsg+0x40/0x4d
[11237.307045]  [<c068db41>] ? sock_sendmsg+0xce/0xe5
[11237.307045]  [<c013ec6d>] ? put_lock_stats+0xd/0x21
[11237.307045]  [<c013416c>] ? autoremove_wake_function+0x0/0x35
[11237.307045]  [<c0142df7>] ? lock_release_non_nested+0xb0/0x1f8
[11237.307045]  [<c017ccb3>] ? might_fault+0x4f/0x8b
[11237.307045]  [<c017ccb3>] ? might_fault+0x4f/0x8b
[11237.307045]  [<c068e4a1>] ? sys_sendto+0xa9/0xc8
[11237.307045]  [<c013ec6d>] ? put_lock_stats+0xd/0x21
[11237.307045]  [<c013ed20>] ? lock_release_holdtime+0x9f/0xa7
[11237.307045]  [<c07b2557>] ? sub_preempt_count+0xc0/0xd1
[11237.307045]  [<c013ec6d>] ? put_lock_stats+0xd/0x21
[11237.307045]  [<c013ed20>] ? lock_release_holdtime+0x9f/0xa7
[11237.307045]  [<c0142df7>] ? lock_release_non_nested+0xb0/0x1f8
[11237.307045]  [<c017ccb3>] ? might_fault+0x4f/0x8b
[11237.307045]  [<c068ec3d>] ? sys_socketcall+0xeb/0x180
[11237.307045]  [<c0102ea1>] ? sysenter_do_call+0x12/0x31
[11237.307045] Code: 0f 45 de 53 ff b0 94 00 00 00 ff b0 90 00 00 00 ff=
 b0 9c 00 00 00 ff b0 98 00 00 00 52 ff 70 50 51 68 1a 32 9d c0 e8 6f 2=
e a9 ff <0f> 0b 83 c4 24 eb fe 55 89 e5 56 53 0f 1f 44 00 00 8b 70 14 b=
b=20
[11237.307045] EIP: [<c06918e1>] skb_under_panic+0x3f/0x46 SS:ESP 0068:=
ca5b5c3c
[11237.374079] ---[ end trace 7188985726996093 ]---

(gdb) l *(ipv6_push_exthdr+0x26)
0xc071d473 is in ipv6_push_exthdr (net/ipv6/exthdrs.c:700).
695		*proto =3D NEXTHDR_ROUTING;
696	}
697=09
698	static void ipv6_push_exthdr(struct sk_buff *skb, u8 *proto, u8 typ=
e, struct ipv6_opt_hdr *opt)
699	{
700		struct ipv6_opt_hdr *h =3D (struct ipv6_opt_hdr *)skb_push(skb, ip=
v6_optlen(opt));
701=09
702		memcpy(h, opt, ipv6_optlen(opt));
703		h->nexthdr =3D *proto;
704		*proto =3D type;


----------------8<------------------------

/*
 * ICMPv6 or ICMPv4 socket fuzzer.
 *
 * Copyright (c) 2006, Cl=C3=A9ment Lecigne
 */
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/param.h>
#include <net/if.h>
//#include <net/if_var.h>
#include <sys/uio.h>
//#include <netinet6/ip6_mroute.h>
//#include <netinet6/in6_var.h>


#define SIOCGETMIFCNT_IN6       SIOCPROTOPRIVATE        /* IP protocol =
privates */
#define SIOCGETSGCNT_IN6        (SIOCPROTOPRIVATE+1)
#define SIOCGETRPF      (SIOCPROTOPRIVATE+2)


/* functions */
unsigned int randaddr(void);
void randsoopt(int);
void randgoopt(int);
void randioctl(int);
void usage(char *);

/*
* boucle until we hit a valid socket option
*/
void randsoopt(int sock)
{
	unsigned int optval;
	int optlen, optname, level, ret, on =3D rand() % 2;
	do
	{
		switch (rand() % 5)
		{
			case 0:
				level =3D IPPROTO_IPV6;
				break;
			case 1:
				level =3D SOL_SOCKET;
				break;
			case 2:
				level =3D IPPROTO_RAW;
				break;
			case 3:
				level =3D rand() & 0xFF;
				break;
			case 4:
				level =3D IPPROTO_IP;
				break;
		}
	=09
		if (rand() % 6)
		{
			optlen =3D rand();
			optval =3D (unsigned int)randaddr();
		}
		else
		{
		/*=20
			* In some cases, kernel excepts that
			* optlen =3D=3D sizeof (int) and that's
			* the first bound checking.
			*/
			optlen =3D sizeof (int);
			on =3D rand();
			optval =3D (unsigned int)&on;
		}
	=09
		if (rand() % 8)
			optname =3D rand() % 255;
		else
			optname =3D rand();
#if 0
		/*
		 * anti well know FreeBSD mbufs exhaustion.
		 */
		if (optname =3D=3D 25 || optname =3D=3D IPV6_IPSEC_POLICY ||=20
				optname =3D=3D IPV6_FW_ADD || optname =3D=3D IPV6_FW_FLUSH
				|| optname =3D=3D IPV6_FW_DEL || optname =3D=3D IPV6_FW_ZERO)
			continue;
		/*printf("level : %d - optname : %d - optlen : %d\n",=20
				level, optname, optlen);*/
#endif
		ret =3D setsockopt(sock, level, optname, (void *)optval, optlen);

	}while(ret =3D=3D -1);
	return;
}


/*
* ioctl ipv6 socket fuzzer.
*/
void randioctl(int sock)
{
	unsigned long reqs[] =3D { SIOCGETSGCNT_IN6, SIOCGETMIFCNT_IN6,
		SIOCGETRPF};
/*
		GSCOPE6DEF, SIOCGLIFADDR, SIOCSIFPHYADDR_IN6, SIOCGIFNETMASK_IN6,
		SIOCAIFADDR_IN6, SIOCGIFDSTADDR_IN6, SIOCSIFALIFETIME_IN6,=20
		SIOCGIFADDR_IN6, SIOCGIFDSTADDR_IN6, SIOCGIFNETMASK_IN6, SIOCGIFAFLAG=
_IN6,
		SIOCGIFSTAT_IN6, SIOCGIFSTAT_ICMP6, SIOCGIFALIFETIME_IN6, SIOCSIFALIF=
ETIME_IN6,
		SIOCAIFADDR_IN6, SIOCDIFADDR_IN6 }; */
	unsigned int arg;
	int ret;
	unsigned long request;
=09
	if (rand() % 8)
		request =3D reqs[rand() % (sizeof (reqs) / sizeof (reqs[0]))];
	else
		request =3D rand() + rand();
	if (rand() % 2)
	{
		arg =3D randaddr();
		ret =3D ioctl(sock, request, (caddr_t)arg);
	}
	else
	{
		arg =3D rand();
		ret =3D ioctl(sock, request, (int)arg);
	}
}


/*
* return a random address
*/
unsigned int randaddr(void)
{
	char *p =3D malloc(1);
	unsigned int heap =3D (unsigned int)p;
	free(p);
	switch (rand() % 4)
	{
		case 0:
			return (heap + (rand() & 0xFFF));
		case 1:
			return ((unsigned int)&heap + (rand() & 0xFFF));
		case 2:
			return (0xc0000000 + (rand() & 0xFFFF));
		case 3:
			return (rand());
	}
	return (0);
}


int main(int ac, char **av)=20
{
	int32_t cc, s, occ, i, j, a, try, count, opts;
	u_int32_t seed, maxsize;
	u_int8_t ip6;
	char c, *buf;
	struct addrinfo *res, hints;
	struct sockaddr_in6 from;
	socklen_t fromlen;
	struct msghdr msg;
	struct cmsghdr *cmsg =3D NULL;
	struct iovec iov;
=09
	/* default values */
	seed =3D getpid();
	count =3D 50;
	occ =3D 10000;
	maxsize =3D 4096;
	opts =3D 50;
	ip6 =3D 1;
	fromlen =3D sizeof(from);
=09
	if (getuid())
	{
		fprintf(stderr, " - you must be root.\n");
		exit(EXIT_FAILURE);
	}
=09
	while ((c =3D getopt(ac, av, "r:n:c:m:o:46")) !=3D EOF)
	{
		switch (c)
		{
			case '6':
				ip6 =3D 1;
				break;
			case '4':
				ip6 =3D 0;
				break;
			case 'r':
				seed =3D atoi(optarg);
				break;
			case 'n':
				occ =3D atoi(optarg);
				break;
			case 'c':
				count =3D atoi(optarg);
				break;
			case 'm':
				maxsize =3D atoi(optarg);
				break;
			case 'o':
				opts =3D atoi(optarg);
				break;
			default:
				usage(av[0]);
				break;
		}
	}
=09
	printf("seeding with %u\n", seed);
	srand(seed);

	buf =3D malloc(maxsize);
	if (buf =3D=3D NULL)
	{
		printf("%s: out of memory.\n", av[0]);
		exit(EXIT_FAILURE);
	}

	memset(&hints, 0, sizeof(hints));
	hints.ai_flags =3D AI_CANONNAME;
	hints.ai_socktype =3D SOCK_RAW;
=09
	if(ip6)
	{
		hints.ai_family =3D AF_INET6;
		hints.ai_protocol =3D IPPROTO_ICMPV6;
		getaddrinfo("::1", NULL, &hints, &res);=20
	}
	else
	{
		hints.ai_family =3D AF_INET;
		hints.ai_protocol =3D IPPROTO_ICMP;
		getaddrinfo("127.0.0.1", NULL, &hints, &res);
	}

	for (i =3D 0; i < occ; i++)
	{
		printf(".\n");
		s =3D socket(res->ai_family, res->ai_socktype, res->ai_protocol);
		//cc =3D bind(s, res->ai_addr, res->ai_addrlen);


		for (j =3D 0; j < opts; j++)
		{
			randsoopt(s);
			//randgoopt(s);
			randioctl(s);

			for (a =3D 0; a < 32; a++)
				buf[a] =3D rand() % 255;

			try =3D 0;
			do
			{
				switch(rand() % 3)
				{
				case 0:
					cc =3D sendto(s, buf, rand() % maxsize, 0,
							(struct sockaddr *)res->ai_addr, res->ai_addrlen);
					break;
				case 1:
				case 2:
					msg.msg_controllen =3D (rand() % 2) ? rand() & maxsize : 0;
					if (msg.msg_controllen)
					{
						if (msg.msg_controllen < sizeof (struct cmsghdr))
							cmsg =3D (struct cmsghdr *)malloc(sizeof (struct cmsghdr));
						else
							cmsg =3D (struct cmsghdr *)malloc(msg.msg_controllen);
						if (cmsg =3D=3D NULL) goto nocmsghdr;
						msg.msg_control =3D cmsg;
						cmsg->cmsg_level =3D (rand() % 2) ? IPPROTO_IPV6 : rand();
						cmsg->cmsg_type =3D (rand() % 2) ? rand() % 255 : rand();
						cmsg->cmsg_len =3D (rand() % 2) ? msg.msg_controllen : rand();
					}
					else
					{
nocmsghdr:
						msg.msg_control =3D (rand() % 5) ? NULL : (void*)randaddr();
						msg.msg_controllen =3D (rand() % 2) ? rand() : 0;
					}
					iov.iov_len =3D (rand() % 2) ? rand() : rand() & maxsize;
					iov.iov_base =3D (rand() % 2) ? (void*)randaddr() : &buf;
					msg.msg_iov =3D (rand() % 2) ? (void*)randaddr() : &iov;
					if (rand() % 5)
					{
						msg.msg_name =3D res->ai_addr;
						msg.msg_namelen =3D res->ai_addrlen;
					}
					else
					{
						msg.msg_name =3D (caddr_t)randaddr();
						msg.msg_namelen =3D rand();
					}
					msg.msg_flags =3D rand();
					cc =3D sendmsg (s, &msg, rand());
				}
				if (cmsg !=3D NULL)
				{=09
				//	free(cmsg);
				//	cmsg =3D NULL;
				}
				try++;
			} while(cc =3D=3D -1 && try !=3D count);=20
			recvmsg(s, &msg, MSG_DONTWAIT);
		}
		close(s);
	}
	free(buf);
	freeaddrinfo(res);
	exit(EXIT_SUCCESS);
}

/*=20
* usage
*/
void usage(char *prog)
{
	printf("usage: %s [-4] [-6] [-r seed] [-c sendto-timeout]\n"
		"          [-m maxsize] [-o maxsetsockopt] [-n occ]\n", prog);
	exit(EXIT_FAILURE);
}
