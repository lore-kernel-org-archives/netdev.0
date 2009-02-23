From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: VM_BUG_ON triggered with udp6fuzz
Date: Mon, 23 Feb 2009 15:22:13 +0100
Message-ID: <20090223142213.GA22327@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:60154 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751944AbZBWOWe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2009 09:22:34 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

first of all, i am not able to replicate this after a clean boot,
running the command sudo -u snakebyte lf6/udp6fuzz -n 100 -r 9343
produced the following BUG on my test box
Not sure where the get_page was triggered from, could not=20
find it in udp6.c ...

[ 7410.317001] ------------[ cut here ]------------
[ 7410.317033] Kernel BUG at c0683663 [verbose debug info unavailable]
[ 7410.317033] invalid opcode: 0000 [#1] PREEMPT DEBUG_PAGEALLOC
[ 7410.317033] last sysfs file: /sys/class/vc/vcs11/dev
[ 7410.317033] Modules linked in: [last unloaded: rcutorture]
[ 7410.317033]=20
[ 7410.317033] Pid: 9343, comm: udp6fuzz Not tainted (2.6.29-rc6 #7)
System Name
[ 7410.317033] EIP: 0060:[<c0683663>] EFLAGS: 00010246 CPU: 0
[ 7410.317033] EIP is at ip6_append_data+0x7df/0x9d5
[ 7410.317033] EAX: 00000000 EBX: 00000000 ECX: 00000004 EDX: c12668a0
[ 7410.317033] ESI: c47889ec EDI: cd5319a0 EBP: cbc2ccc4 ESP: cbc2cc70
[ 7410.317033]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 7410.317033] Process udp6fuzz (pid: 9343, ti=3Dcbc2c000 task=3Dc46300=
00
task.ti=3Dcbc2c000)
[ 7410.317033] Stack:
[ 7410.317033]  cbc2cf50 c063fbf2 cd434000 00000000 00000028 00000000
00000010 00004034
[ 7410.317033]  00000000 cbc2cc9c c013e492 cbc2cca8 c12668a0 00000cee
00004028 00000000
[ 7410.317033]  00000000 00000002 00000cee cbc2cf34 cd434000 cbc2cdb4
c0693ba6 00000cee
[ 7410.317033] Call Trace:
[ 7410.317033]  [<c063fbf2>] ? ip_generic_getfrag+0x0/0x8f
[ 7410.317033]  [<c013e492>] ? trace_hardirqs_on+0xb/0xd
[ 7410.317033]  [<c0693ba6>] ? udpv6_sendmsg+0x751/0x9ee
[ 7410.317033]  [<c013fc3d>] ? __lock_acquire+0x6a8/0x6fe
[ 7410.317033]  [<c0106d88>] ? native_sched_clock+0x41/0x68
[ 7410.317033]  [<c012582c>] ? local_bh_enable_ip+0xa0/0xb8
[ 7410.317033]  [<c013e449>] ? trace_hardirqs_on_caller+0x10d/0x14b
[ 7410.317033]  [<c0613b8c>] ? release_sock+0xb1/0xb9
[ 7410.317033]  [<c013e492>] ? trace_hardirqs_on+0xb/0xd
[ 7410.317033]  [<c012582c>] ? local_bh_enable_ip+0xa0/0xb8
[ 7410.317033]  [<c065e0d7>] ? inet_sendmsg+0x3b/0x48
[ 7410.317033]  [<c061218f>] ? sock_sendmsg+0xc9/0xe0
[ 7410.317033]  [<c013bcfd>] ? put_lock_stats+0xd/0x21
[ 7410.317033]  [<c01315c9>] ? autoremove_wake_function+0x0/0x30
[ 7410.317033]  [<c013fdba>] ? lock_release_non_nested+0xb0/0x1f8
[ 7410.317033]  [<c0174812>] ? might_fault+0x4a/0x86
[ 7410.317033]  [<c0174812>] ? might_fault+0x4a/0x86
[ 7410.317033]  [<c0612a88>] ? sys_sendto+0xa4/0xc3
[ 7410.317033]  [<c0106d88>] ? native_sched_clock+0x41/0x68
[ 7410.317033]  [<c013bcfd>] ? put_lock_stats+0xd/0x21
[ 7410.317033]  [<c013bdb0>] ? lock_release_holdtime+0x9f/0xa7
[ 7410.317033]  [<c013fdba>] ? lock_release_non_nested+0xb0/0x1f8
[ 7410.317033]  [<c0174812>] ? might_fault+0x4a/0x86
[ 7410.317033]  [<c06131d7>] ? sys_socketcall+0xe6/0x17b
[ 7410.317033]  [<c0102dc1>] ? sysenter_do_call+0x12/0x31
[ 7410.317033] Code: 74 02 0c 8b 55 dc 3b 16 0f 84 e9 00 00 00 66 83 fb
12 0f 84 d6 00 00 00 8b 55 dc f6 42 01 40 74 03 8b 52 0c 8b 42 04 85 c0
75 04 <0f> 0b eb fe ff 42 04 8b 75 b4 6b 55 b8 0c 8b 87 94 00 00 00 8b=20
[ 7410.317033] EIP: [<c0683663>] ip6_append_data+0x7df/0x9d5 SS:ESP
0068:cbc2cc70
[ 7410.408156] ---[ end trace 228f803a591a2d43 ]---


0xc0683663 is in ip6_append_data (include/linux/mm.h:302).
297	}
298=09
299	static inline void get_page(struct page *page)
300	{
301		page =3D compound_head(page);
302		VM_BUG_ON(atomic_read(&page->_count) =3D=3D 0);
303		atomic_inc(&page->_count);
304	}
305=09
306	static inline struct page *virt_to_head_page(const void *x)


The fuzzer used:

---------------------------8<-----------------------------
/*
 * UDP/IPv6 or UDP/IPv6 socket fuzzer.
 *
 * Copyright (C) 2006, Cl=C3=A9ment Lecigne
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

unsigned int randaddr(void);
void randsoopt(int);
void randgoopt(int);
void randioctl(int);
void usage(char *);
void fuzzlog(char *func, char *fmt, ...);

unsigned int count =3D 0;

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
				level =3D IPPROTO_UDP;
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
			* generally the first bound checking.
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
	=09
#if 0
		/*
		 * anti well know mbufs exhaustion. (FreeBSD)
		 */
		if (optname =3D=3D 25 || optname =3D=3D IPV6_IPSEC_POLICY ||=20
				optname =3D=3D IPV6_FW_ADD || optname =3D=3D IPV6_FW_FLUSH
				|| optname =3D=3D IPV6_FW_DEL || optname =3D=3D IPV6_FW_ZERO)
			continue;
#endif
		ret =3D setsockopt(sock, level, optname, (void *)optval, optlen);

	}while(ret =3D=3D -1);
}


/*
* ioctl fuzzer.
*/
void randioctl(int sock)
{
	unsigned long reqs[] =3D { SIOCGETSGCNT_IN6, SIOCGETMIFCNT_IN6,
		SIOCGETRPF};
/*		SIOCGSCOPE6DEF, SIOCGLIFADDR, SIOCSIFPHYADDR_IN6, SIOCGIFNETMASK_IN=
6,
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
* return a possible random mapped address
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
	int32_t cc, s, occ, i, j, try, count, opts;
	u_int32_t seed, maxsize;
	u_int8_t ip6;
	char c, *buf, *port =3D "1337";
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
	occ =3D 1000;
	maxsize =3D 4096;
	opts =3D 50;
	ip6 =3D 1;
	fromlen =3D sizeof(from);
=09
	while ((c =3D getopt(ac, av, "r:n:c:p:m:o:f:l:46")) !=3D EOF)
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
			case 'p':
				port =3D optarg;
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
		exit(1);
	}

	memset(&hints, 0, sizeof(hints));
	hints.ai_socktype =3D SOCK_DGRAM;
	hints.ai_protocol =3D IPPROTO_UDP;
=09
	if(ip6)
	{
		hints.ai_family =3D AF_INET6;
		getaddrinfo("::1", port, &hints, &res);
	}
	else
	{
		hints.ai_family =3D AF_INET;
		getaddrinfo("127.0.0.1", port, &hints, &res);
	}

	for (i =3D 0; i < occ; i++)
	{
		s =3D socket(res->ai_family, res->ai_socktype, res->ai_protocol);
		cc =3D bind(s, res->ai_addr, res->ai_addrlen);


		for (j =3D 0; j < opts; j++)
		{
			randsoopt(s);
			randioctl(s);

			try =3D 0;
			do
			{
				switch(rand() % 3)
				{
				case 0:
					cc =3D sendto(s, &buf, rand() % maxsize, rand() % 8,
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
					iov.iov_base =3D (rand() % 2) ? (void*)randaddr() : &s;
					msg.msg_iov =3D (rand() % 2) ? (void*)randaddr() : &iov;
					if (rand() % 10)
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
				{
					//free(cmsg);
					//cmsg =3D NULL;
				}
				try++;
			} while(cc =3D=3D -1 && try !=3D count);=20
			recvmsg(s, &msg, MSG_DONTWAIT);
		}
		close(s);
	}
	free(buf);
	freeaddrinfo(res);
	exit(0);
}

/*=20
* usage
*/
void usage(char *prog)
{
	printf("usage: %s [-4] [-6] [-r seed] [-c sendto-timeout]\n"
		"          [-m maxsize] [-o maxsetsockopt] [-n occ]\n"
		"          [-p udp-port]\n", prog);
	exit(1);
}
