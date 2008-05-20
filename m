From: Eric Sesterhenn <snakebyte@gmx.de>
Subject: oops in skb_under_panic with linux-next
Date: Tue, 20 May 2008 19:49:12 +0200
Message-ID: <20080520174912.GA6231@alice>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:40216 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1754758AbYETRu1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 13:50:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hi,

i saw the following oops with linux-next from today
running icmpv6fuzz -r  2187
I was able to reproduce this, but didnt try rebooting and reproducing
since i am currently not at home

[ 5354.117714] invalid cmsg type: 1035331808
[ 5354.117896] icmpv6: msg of unknown type
[ 5354.161756] skb_under_panic: text:c056ccf7 len:1256 put:864
head:c21db5e0 data:c21db338 tail:0xc21db698 end:0xc21db6a0 dev:<NULL>
[ 5354.170788] ------------[ cut here ]------------
[ 5354.170909] kernel BUG at net/core/skbuff.c:149!
[ 5354.170986] invalid opcode: 0000 [#2] PREEMPT DEBUG_PAGEALLOC
[ 5354.171210] Modules linked in: nfsd exportfs
[ 5354.171344]=20
[ 5354.171344] Pid: 2187, comm: icmpv6fuzz Tainted: G      D
(2.6.26-rc3 #26)
[ 5354.171344] EIP: 0060:[<c04cfbfc>] EFLAGS: 00010282 CPU: 0
[ 5354.171344] EIP is at skb_under_panic+0x5c/0x60
[ 5354.171344] EAX: 00000088 EBX: c21db5e0 ECX: 10000000 EDX: 00000000
[ 5354.171344] ESI: 00000000 EDI: c617dc30 EBP: c3d1cc48 ESP: c3d1cc1c
[ 5354.171344]  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
[ 5354.171344] Process icmpv6fuzz (pid: 2187, ti=3Dc3d1c000 task=3Dc45c=
1f80
task.ti=3Dc3d1c000)
[ 5354.171344] Stack: c076f6ec c056ccf7 000004e8 00000360 c21db5e0
c21db338 c21db698 c21db6a0=20
[ 5354.171344]        c07383b3 cb9008c0 c61b50fc c3d1cc54 c04d0c0a
c3d1ccb3 c3d1cc70 c056ccf7=20
[ 5354.171344]        0000003c 00000005 cb9008c0 cf199584 c617dc30
c3d1cc80 c056cd53 c61b50fc=20
[ 5354.171344] Call Trace:
[ 5354.171344]  [<c056ccf7>] ? ipv6_push_exthdr+0x27/0x60
[ 5354.171344]  [<c04d0c0a>] ? skb_push+0x2a/0x40
[ 5354.171344]  [<c056ccf7>] ? ipv6_push_exthdr+0x27/0x60
[ 5354.171344]  [<c056cd53>] ? ipv6_push_frag_opts+0x23/0x30
[ 5354.171344]  [<c054b678>] ? ip6_push_pending_frames+0x1c8/0x410
[ 5354.171344]  [<c04d02ac>] ? skb_store_bits+0x11c/0x230
[ 5354.171344]  [<c0560ddc>] ? rawv6_sendmsg+0xa8c/0xce0
[ 5354.171344]  [<c017a3f1>] ? check_bytes_and_report+0x21/0xc0
[ 5354.171344]  [<c017a0d3>] ? slab_pad_check+0x73/0x110
[ 5354.171344]  [<c0521714>] ? inet_sendmsg+0x34/0x60
[ 5354.171344]  [<c04cae44>] ? sock_sendmsg+0xc4/0xf0
[ 5354.171344]  [<c017b813>] ? __slab_free+0x63/0x2e0
[ 5354.171344]  [<c0138420>] ? autoremove_wake_function+0x0/0x40
[ 5354.171344]  [<c04caf9f>] ? sys_sendmsg+0x12f/0x230
[ 5354.171344]  [<c036daa6>] ? copy_from_user+0x46/0x80
[ 5354.171344]  [<c04cb145>] ? sys_sendto+0xa5/0xd0
[ 5354.171344]  [<c04cce8f>] ? release_sock+0xbf/0xd0
[ 5354.171344]  [<c05fe0af>] ? _spin_unlock_bh+0x2f/0x40
[ 5354.171344]  [<c04cc36e>] ? sock_ioctl+0x6e/0x1b0
[ 5354.171344]  [<c04cbffd>] ? sys_socketcall+0x13d/0x260
[ 5354.171344]  [<c0103d7d>] ? sysenter_past_esp+0x6a/0xb1
[ 5354.171344]  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
[ 5354.171344] Code: 00 00 89 5c 24 14 8b 98 90 00 00 00 89 54 24 0c 89
5c 24 10 8b 40 50 89 4c 24 04 c7 04 24 ec f6 76 c0 89 44 24 08 e8 a4 69
c5 ff <0f> 0b eb fe 55 89 e5 56 53 bb b3 83 73 c0 83 ec 24 8b 70 14 85=20
[ 5354.171344] EIP: [<c04cfbfc>] skb_under_panic+0x5c/0x60 SS:ESP
0068:c3d1cc1c
[ 5354.253156] ---[ end trace 0ab24c034e0bf829 ]---


here is the sourcecode for icmpv6fuzz in case this makes the bughunting
easier



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
