From: Eric Sesterhenn <eric.sesterhenn@lsexperts.de>
Subject: Soft lockup caused by icmpv6fuzz
Date: Mon, 29 Jun 2009 15:14:30 +0200
Message-ID: <1246281270.3688.10.camel@queen>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-srDOQPa9ejTN9YRdxF2/"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pawisda.de ([213.157.4.156]:35000 "EHLO
	mailrelay.pawisda.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752276AbZF2Nia (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Jun 2009 09:38:30 -0400
Received: from [192.168.0.2] (193.195.116.85.dsl.manitu.net [85.116.195.193])
	by mailrelay.pawisda.de (Postfix) with ESMTP id 5AAB9B8BA6
	for <netdev@vger.kernel.org>; Mon, 29 Jun 2009 15:14:31 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-srDOQPa9ejTN9YRdxF2/
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

hi,

with todays -git, my test box dies while running

icmpv6fuzz -r 29765


[ 9461.816017] BUG: soft lockup - CPU#0 stuck for 61s!
[icmpv6fuzz:29765]
[ 9461.816017] Modules linked in: ip6table_filter ip6_tables af_packet
nfsd exportfs nfs lockd nfs_acl auth_rpcgss sunrpc ipv6 fuse unix [last
unloaded: rcutorture]
[ 9461.816017] irq event stamp: 0
[ 9461.816017] hardirqs last  enabled at (0): [<(null)>] (null)
[ 9461.816017] hardirqs last disabled at (0): [<c0126996>] copy_process
+0x256/0x1100
[ 9461.816017] softirqs last  enabled at (0): [<c0126996>] copy_process
+0x256/0x1100
[ 9461.816017] softirqs last disabled at (0): [<(null)>] (null)
[ 9461.816017] 
[ 9461.816017] Pid: 29765, comm: icmpv6fuzz Not tainted (2.6.31-rc1
#11) 
[ 9461.816017] EIP: 0060:[<d08d7fe5>] EFLAGS: 00010246 CPU: 0
[ 9461.816017] EIP is at __raw_v6_lookup+0x15/0x130 [ipv6]
[ 9461.816017] EAX: caf81e20 EBX: 00000001 ECX: 0000003a EDX: 00000000
[ 9461.816017] ESI: cf9f1ca0 EDI: caf5df38 EBP: c08c0e74 ESP: c08c0e54
[ 9461.816017]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[ 9461.816017] CR0: 8005003b CR2: caf81e20 CR3: 0e767000 CR4: 00000690
[ 9461.816017] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[ 9461.816017] DR6: ffff0ff0 DR7: 00000400
[ 9461.816017] Call Trace:
[ 9461.816017]  [<d08d8684>] raw6_local_deliver+0x134/0x210 [ipv6]
[ 9461.816017]  [<d08c3408>] ip6_input_finish+0xe8/0x370 [ipv6]
[ 9461.816017]  [<d08c3320>] ? ip6_input_finish+0x0/0x370 [ipv6]
[ 9461.816017]  [<d08c36e7>] ip6_input+0x57/0x60 [ipv6]
[ 9461.816017]  [<d08c3320>] ? ip6_input_finish+0x0/0x370 [ipv6]
[ 9461.816017]  [<d08c2f82>] ip6_rcv_finish+0x12/0x30 [ipv6]
[ 9461.816017]  [<d08c32bf>] ipv6_rcv+0x31f/0x380 [ipv6]
[ 9461.816017]  [<d08c2fbd>] ? ipv6_rcv+0x1d/0x380 [ipv6]
[ 9461.816017]  [<c0519e14>] netif_receive_skb+0x314/0x420
[ 9461.816017]  [<c0519c38>] ? netif_receive_skb+0x138/0x420
[ 9461.816017]  [<c0519f7a>] process_backlog+0x5a/0xa0
[ 9461.816017]  [<c051a77c>] net_rx_action+0x13c/0x1f0
[ 9461.816017]  [<c051a70a>] ? net_rx_action+0xca/0x1f0
[ 9461.816017]  [<c012d20f>] __do_softirq+0x7f/0x120
[ 9461.816017]  [<c012d190>] ? __do_softirq+0x0/0x120
[ 9461.816017]  <IRQ>  [<c051c2a2>] ? dev_queue_xmit+0x112/0x4d0
[ 9461.816017]  [<c012d0e7>] ? local_bh_enable+0xa7/0xb0
[ 9461.816017]  [<c051c2a2>] ? dev_queue_xmit+0x112/0x4d0
[ 9461.816017]  [<c051c1c8>] ? dev_queue_xmit+0x38/0x4d0
[ 9461.816017]  [<d08c0353>] ? ip6_output_finish+0x73/0xc0 [ipv6]
[ 9461.816017]  [<d08c23d8>] ? ip6_output2+0x128/0x200 [ipv6]
[ 9461.816017]  [<d08c29bd>] ? ip6_output+0x50d/0xac0 [ipv6]
[ 9461.816017]  [<c053ed99>] ? nf_iterate+0x69/0x80
[ 9461.816017]  [<c053f036>] ? nf_hook_slow+0xf6/0x110
[ 9461.816017]  [<d08c00f0>] ? dst_output+0x0/0x10 [ipv6]
[ 9461.816017]  [<d08c18b2>] ? __ip6_local_out+0x72/0x80 [ipv6]
[ 9461.816017]  [<d08c18d8>] ? ip6_local_out+0x18/0x30 [ipv6]
[ 9461.816017]  [<d08c1c35>] ? ip6_push_pending_frames+0x345/0x400
[ipv6]
[ 9461.816017]  [<d08d7a16>] ? rawv6_sendmsg+0xc26/0xc90 [ipv6]
[ 9461.816017]  [<c02f676c>] ? copy_from_user+0x4c/0x130
[ 9461.816017]  [<c011ac8b>] ? __bad_area_nosemaphore+0x5b/0x170
[ 9461.816017]  [<c014ddcb>] ? trace_hardirqs_on+0xb/0x10
[ 9461.816017]  [<c012d490>] ? local_bh_enable_ip+0x60/0xb0
[ 9461.816017]  [<c05c9463>] ? i2o_pci_probe+0x4c3/0x6c0
[ 9461.816017]  [<c013a2b7>] ? search_exception_tables+0x17/0x40
[ 9461.816017]  [<c02f5e8d>] ? __get_user_4+0x11/0x17
[ 9461.816017]  [<c0592764>] ? inet_sendmsg+0x34/0x60
[ 9461.816017]  [<c050c499>] ? sock_sendmsg+0xe9/0x110
[ 9461.816017]  [<c013c670>] ? autoremove_wake_function+0x0/0x50
[ 9461.816017]  [<c0103177>] ? restore_all_notrace+0x0/0x18
[ 9461.816017]  [<c0184751>] ? might_fault+0x91/0xa0
[ 9461.816017]  [<c0184706>] ? might_fault+0x46/0xa0
[ 9461.816017]  [<c02f6755>] ? copy_from_user+0x35/0x130
[ 9461.816017]  [<c050c880>] ? sys_sendto+0xf0/0x130
[ 9461.816017]  [<c050a8d0>] ? sock_ioctl+0x0/0x240
[ 9461.816017]  [<c0184751>] ? might_fault+0x91/0xa0
[ 9461.816017]  [<c0184706>] ? might_fault+0x46/0xa0
[ 9461.816017]  [<c050cfbb>] ? sys_socketcall+0x18b/0x2a0
[ 9461.816017]  [<c010305b>] ? sysenter_do_call+0x12/0x32



[  667.868016] BUG: soft lockup - CPU#0 stuck for 61s! [icmpv6fuzz:3995]
[  667.868016] Modules linked in: nfsd exportfs nfs lockd nfs_acl
auth_rpcgss sunrpc ipv6 fuse unix
[  667.868016] irq event stamp: 0
[  667.868016] hardirqs last  enabled at (0): [<(null)>] (null)
[  667.868016] hardirqs last disabled at (0): [<c0126996>] copy_process
+0x256/0x1100
[  667.868016] softirqs last  enabled at (0): [<c0126996>] copy_process
+0x256/0x1100
[  667.868016] softirqs last disabled at (0): [<(null)>] (null)
[  667.868016] 
[  667.868016] Pid: 3995, comm: icmpv6fuzz Not tainted (2.6.31-rc1 #11) 
[  667.868016] EIP: 0060:[<d0851fe5>] EFLAGS: 00010246 CPU: 0
[  667.868016] EIP is at __raw_v6_lookup+0x15/0x130 [ipv6]
[  667.868016] EAX: c355de20 EBX: 00000001 ECX: 0000003a EDX: 00000000
[  667.868016] ESI: c3557ca0 EDI: c355af38 EBP: c08c0e74 ESP: c08c0e54
[  667.868016]  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
[  667.868016] CR0: 8005003b CR2: c355de20 CR3: 03534000 CR4: 00000690
[  667.868016] DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
[  667.868016] DR6: ffff0ff0 DR7: 00000400
[  667.868016] Call Trace:
[  667.868016]  [<d0852684>] raw6_local_deliver+0x134/0x210 [ipv6]
[  667.868016]  [<d083d408>] ip6_input_finish+0xe8/0x370 [ipv6]
[  667.868016]  [<d083d320>] ? ip6_input_finish+0x0/0x370 [ipv6]
[  667.868016]  [<d083d6e7>] ip6_input+0x57/0x60 [ipv6]
[  667.868016]  [<d083cf82>] ip6_rcv_finish+0x12/0x30 [ipv6]
[  667.868016]  [<d083d2bf>] ipv6_rcv+0x31f/0x380 [ipv6]
[  667.868016]  [<d083cfbd>] ? ipv6_rcv+0x1d/0x380 [ipv6]
[  667.868016]  [<c0519e14>] netif_receive_skb+0x314/0x420
[  667.868016]  [<c0519c38>] ? netif_receive_skb+0x138/0x420
[  667.868016]  [<c0519f7a>] process_backlog+0x5a/0xa0
[  667.868016]  [<c051a77c>] net_rx_action+0x13c/0x1f0
[  667.868016]  [<c051a70a>] ? net_rx_action+0xca/0x1f0
[  667.868016]  [<c012d20f>] __do_softirq+0x7f/0x120
[  667.868016]  [<c012d190>] ? __do_softirq+0x0/0x120
[  667.868016]  <IRQ>  [<c051c2a2>] ? dev_queue_xmit+0x112/0x4d0
[  667.868016]  [<c012d0e7>] ? local_bh_enable+0xa7/0xb0
[  667.868016]  [<c051c2a2>] ? dev_queue_xmit+0x112/0x4d0
[  667.868016]  [<c051c1c8>] ? dev_queue_xmit+0x38/0x4d0
[  667.868016]  [<d083a353>] ? ip6_output_finish+0x73/0xc0 [ipv6]
[  667.868016]  [<d083c3d8>] ? ip6_output2+0x128/0x200 [ipv6]
[  667.868016]  [<d083c9bd>] ? ip6_output+0x50d/0xac0 [ipv6]
[  667.868016]  [<c056bf8e>] ? ip_generic_getfrag+0x3e/0xb0
[  667.868016]  [<d083a6a1>] ? ip6_append_data+0x231/0xb10 [ipv6]
[  667.868016]  [<c056bf50>] ? ip_generic_getfrag+0x0/0xb0
[  667.868016]  [<d083b8d8>] ? ip6_local_out+0x18/0x30 [ipv6]
[  667.868016]  [<d083bc35>] ? ip6_push_pending_frames+0x345/0x400
[ipv6]
[  667.868016]  [<d0851a16>] ? rawv6_sendmsg+0xc26/0xc90 [ipv6]
[  667.868016]  [<c02f676c>] ? copy_from_user+0x4c/0x130
[  667.868016]  [<c011ac8b>] ? __bad_area_nosemaphore+0x5b/0x170
[  667.868016]  [<c014ddcb>] ? trace_hardirqs_on+0xb/0x10
[  667.868016]  [<c012d490>] ? local_bh_enable_ip+0x60/0xb0
[  667.868016]  [<c05ca394>] ? piix4_probe+0x574/0x68d
[  667.868016]  [<c011b91e>] ? fixup_exception+0xe/0x50
[  667.868016]  [<c0592764>] ? inet_sendmsg+0x34/0x60
[  667.868016]  [<c050c499>] ? sock_sendmsg+0xe9/0x110
[  667.868016]  [<c0184706>] ? might_fault+0x46/0xa0
[  667.868016]  [<c013c670>] ? autoremove_wake_function+0x0/0x50
[  667.868016]  [<c0184751>] ? might_fault+0x91/0xa0
[  667.868016]  [<c0184706>] ? might_fault+0x46/0xa0
[  667.868016]  [<c02f6755>] ? copy_from_user+0x35/0x130
[  667.868016]  [<c050c880>] ? sys_sendto+0xf0/0x130
[  667.868016]  [<c050a8d0>] ? sock_ioctl+0x0/0x240
[  667.868016]  [<c0184751>] ? might_fault+0x91/0xa0
[  667.868016]  [<c0184706>] ? might_fault+0x46/0xa0
[  667.868016]  [<c050cfbb>] ? sys_socketcall+0x18b/0x2a0
[  667.868016]  [<c010305b>] ? sysenter_do_call+0x12/0x32



(gdb) l *(ip6_input_finish+0xe8)
0x5408 is in ip6_input_finish (net/ipv6/ip6_input.c:184).
179		nexthdr = skb_network_header(skb)[nhoff];
180	
181		raw = raw6_local_deliver(skb, nexthdr);
182	
183		hash = nexthdr & (MAX_INET_PROTOS - 1);
184		if ((ipprot = rcu_dereference(inet6_protos[hash])) != NULL) {
185			int ret;
186	
187			if (ipprot->flags & INET6_PROTO_FINAL) {
188				struct ipv6hdr *hdr;
(gdb) l *(raw6_local_deliver+0x134)
0x1a684 is in raw6_local_deliver (net/ipv6/raw.c:176).
171			goto out;
172	
173		net = dev_net(skb->dev);
174		sk = __raw_v6_lookup(net, sk, nexthdr, daddr, saddr,
IP6CB(skb)->iif);
175	
176		while (sk) {
177			int filtered;
178	
179			delivered = 1;
180			switch (nexthdr) {


The testcase itself is attached, please let me know if you
need further information

Regards, Eric




--=-srDOQPa9ejTN9YRdxF2/
Content-Disposition: attachment; filename=icmpv6fuzz.c
Content-Type: text/x-csrc; name=icmpv6fuzz.c; charset=UTF-8
Content-Transfer-Encoding: 8bit

/*
 * ICMPv6 or ICMPv4 socket fuzzer.
 *
 * Copyright (c) 2006, Clément Lecigne
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


#define SIOCGETMIFCNT_IN6       SIOCPROTOPRIVATE        /* IP protocol privates */
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
	int optlen, optname, level, ret, on = rand() % 2;
	do
	{
		switch (rand() % 5)
		{
			case 0:
				level = IPPROTO_IPV6;
				break;
			case 1:
				level = SOL_SOCKET;
				break;
			case 2:
				level = IPPROTO_RAW;
				break;
			case 3:
				level = rand() & 0xFF;
				break;
			case 4:
				level = IPPROTO_IP;
				break;
		}
		
		if (rand() % 6)
		{
			optlen = rand();
			optval = (unsigned int)randaddr();
		}
		else
		{
		/* 
			* In some cases, kernel excepts that
			* optlen == sizeof (int) and that's
			* the first bound checking.
			*/
			optlen = sizeof (int);
			on = rand();
			optval = (unsigned int)&on;
		}
		
		if (rand() % 8)
			optname = rand() % 255;
		else
			optname = rand();
#if 0
		/*
		 * anti well know FreeBSD mbufs exhaustion.
		 */
		if (optname == 25 || optname == IPV6_IPSEC_POLICY || 
				optname == IPV6_FW_ADD || optname == IPV6_FW_FLUSH
				|| optname == IPV6_FW_DEL || optname == IPV6_FW_ZERO)
			continue;
		/*printf("level : %d - optname : %d - optlen : %d\n", 
				level, optname, optlen);*/
#endif
		ret = setsockopt(sock, level, optname, (void *)optval, optlen);

	}while(ret == -1);
	return;
}


/*
* ioctl ipv6 socket fuzzer.
*/
void randioctl(int sock)
{
	unsigned long reqs[] = { SIOCGETSGCNT_IN6, SIOCGETMIFCNT_IN6,
		SIOCGETRPF};
/*
		GSCOPE6DEF, SIOCGLIFADDR, SIOCSIFPHYADDR_IN6, SIOCGIFNETMASK_IN6,
		SIOCAIFADDR_IN6, SIOCGIFDSTADDR_IN6, SIOCSIFALIFETIME_IN6, 
		SIOCGIFADDR_IN6, SIOCGIFDSTADDR_IN6, SIOCGIFNETMASK_IN6, SIOCGIFAFLAG_IN6,
		SIOCGIFSTAT_IN6, SIOCGIFSTAT_ICMP6, SIOCGIFALIFETIME_IN6, SIOCSIFALIFETIME_IN6,
		SIOCAIFADDR_IN6, SIOCDIFADDR_IN6 }; */
	unsigned int arg;
	int ret;
	unsigned long request;
	
	if (rand() % 8)
		request = reqs[rand() % (sizeof (reqs) / sizeof (reqs[0]))];
	else
		request = rand() + rand();
	if (rand() % 2)
	{
		arg = randaddr();
		ret = ioctl(sock, request, (caddr_t)arg);
	}
	else
	{
		arg = rand();
		ret = ioctl(sock, request, (int)arg);
	}
}


/*
* return a random address
*/
unsigned int randaddr(void)
{
	char *p = malloc(1);
	unsigned int heap = (unsigned int)p;
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


int main(int ac, char **av) 
{
	int32_t cc, s, occ, i, j, a, try, count, opts;
	u_int32_t seed, maxsize;
	u_int8_t ip6;
	char c, *buf;
	struct addrinfo *res, hints;
	struct sockaddr_in6 from;
	socklen_t fromlen;
	struct msghdr msg;
	struct cmsghdr *cmsg = NULL;
	struct iovec iov;
	
	/* default values */
	seed = getpid();
	count = 50;
	occ = 10000;
	maxsize = 4096;
	opts = 50;
	ip6 = 1;
	fromlen = sizeof(from);
	
	if (getuid())
	{
		fprintf(stderr, " - you must be root.\n");
		exit(EXIT_FAILURE);
	}
	
	while ((c = getopt(ac, av, "r:n:c:m:o:46")) != EOF)
	{
		switch (c)
		{
			case '6':
				ip6 = 1;
				break;
			case '4':
				ip6 = 0;
				break;
			case 'r':
				seed = atoi(optarg);
				break;
			case 'n':
				occ = atoi(optarg);
				break;
			case 'c':
				count = atoi(optarg);
				break;
			case 'm':
				maxsize = atoi(optarg);
				break;
			case 'o':
				opts = atoi(optarg);
				break;
			default:
				usage(av[0]);
				break;
		}
	}
	
	printf("seeding with %u\n", seed);
	srand(seed);

	buf = malloc(maxsize);
	if (buf == NULL)
	{
		printf("%s: out of memory.\n", av[0]);
		exit(EXIT_FAILURE);
	}

	memset(&hints, 0, sizeof(hints));
	hints.ai_flags = AI_CANONNAME;
	hints.ai_socktype = SOCK_RAW;
	
	if(ip6)
	{
		hints.ai_family = AF_INET6;
		hints.ai_protocol = IPPROTO_ICMPV6;
		getaddrinfo("::1", NULL, &hints, &res); 
	}
	else
	{
		hints.ai_family = AF_INET;
		hints.ai_protocol = IPPROTO_ICMP;
		getaddrinfo("127.0.0.1", NULL, &hints, &res);
	}

	for (i = 0; i < occ; i++)
	{
		printf(".\n");
		s = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
		//cc = bind(s, res->ai_addr, res->ai_addrlen);


		for (j = 0; j < opts; j++)
		{
			randsoopt(s);
			//randgoopt(s);
			randioctl(s);

			for (a = 0; a < 32; a++)
				buf[a] = rand() % 255;

			try = 0;
			do
			{
				switch(rand() % 3)
				{
				case 0:
					cc = sendto(s, buf, rand() % maxsize, 0,
							(struct sockaddr *)res->ai_addr, res->ai_addrlen);
					break;
				case 1:
				case 2:
					msg.msg_controllen = (rand() % 2) ? rand() & maxsize : 0;
					if (msg.msg_controllen)
					{
						if (msg.msg_controllen < sizeof (struct cmsghdr))
							cmsg = (struct cmsghdr *)malloc(sizeof (struct cmsghdr));
						else
							cmsg = (struct cmsghdr *)malloc(msg.msg_controllen);
						if (cmsg == NULL) goto nocmsghdr;
						msg.msg_control = cmsg;
						cmsg->cmsg_level = (rand() % 2) ? IPPROTO_IPV6 : rand();
						cmsg->cmsg_type = (rand() % 2) ? rand() % 255 : rand();
						cmsg->cmsg_len = (rand() % 2) ? msg.msg_controllen : rand();
					}
					else
					{
nocmsghdr:
						msg.msg_control = (rand() % 5) ? NULL : (void*)randaddr();
						msg.msg_controllen = (rand() % 2) ? rand() : 0;
					}
					iov.iov_len = (rand() % 2) ? rand() : rand() & maxsize;
					iov.iov_base = (rand() % 2) ? (void*)randaddr() : &buf;
					msg.msg_iov = (rand() % 2) ? (void*)randaddr() : &iov;
					if (rand() % 5)
					{
						msg.msg_name = res->ai_addr;
						msg.msg_namelen = res->ai_addrlen;
					}
					else
					{
						msg.msg_name = (caddr_t)randaddr();
						msg.msg_namelen = rand();
					}
					msg.msg_flags = rand();
					cc = sendmsg (s, &msg, rand());
				}
				if (cmsg != NULL)
				{	
				//	free(cmsg);
				//	cmsg = NULL;
				}
				try++;
			} while(cc == -1 && try != count); 
			recvmsg(s, &msg, MSG_DONTWAIT);
		}
		close(s);
	}
	free(buf);
	freeaddrinfo(res);
	exit(EXIT_SUCCESS);
}

/* 
* usage
*/
void usage(char *prog)
{
	printf("usage: %s [-4] [-6] [-r seed] [-c sendto-timeout]\n"
		"          [-m maxsize] [-o maxsetsockopt] [-n occ]\n", prog);
	exit(EXIT_FAILURE);
}

--=-srDOQPa9ejTN9YRdxF2/--

