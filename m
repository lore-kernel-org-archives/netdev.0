From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] phonet: Check input from user before allocating
Date: Tue, 03 Apr 2012 05:14:04 +0200
Message-ID: <1333422844.18626.26.camel@edumazet-glaptop>
References: <1333417997.18626.1.camel@edumazet-glaptop>
	 <20120402.215911.1929019308299701014.davem@davemloft.net>
	 <1333419304.18626.5.camel@edumazet-glaptop>
	 <20120402.222300.1137842205135530387.davem@davemloft.net>
	 <4F7A60A4.5040600@hp.com> <1333420452.18626.11.camel@edumazet-glaptop>
	 <4F7A62FE.2050103@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, remi@remlab.net,
	levinsasha928@gmail.com, remi.denis-courmont@nokia.com,
	davej@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:44341 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487Ab2DCDOJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 23:14:09 -0400
In-Reply-To: <4F7A62FE.2050103@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-02 at 19:39 -0700, Rick Jones wrote:
> On 04/02/2012 07:34 PM, Eric Dumazet wrote:
> > On Mon, 2012-04-02 at 19:29 -0700, Rick Jones wrote:
> >> I don't know it isn't entirely bitrotted, but there are streaming and
> >> datagram AF_UNIX tests in netperf - they require conditional inclusion
> >> via ./configure --enable-unixdomain:
> >>
> >> http://www.netperf.org/svn/netperf2/trunk/doc/netperf.html#DG_005fSTREAM
> >>
> >
> > Ah yes of course, I'll try that.
> >

It seems netperf has some problems zith AF_UNIX dgram :

socket(PF_FILE, SOCK_DGRAM, 0)          = 4
setsockopt(4, SOL_SOCKET, SO_SNDBUF, [0], 4) = 0
getsockopt(4, SOL_SOCKET, SO_SNDBUF, [2048], [4]) = 0
setsockopt(4, SOL_SOCKET, SO_RCVBUF, [0], 4) = 0
getsockopt(4, SOL_SOCKET, SO_RCVBUF, [2288], [4]) = 0
sendto(3, "\0\0\0+\377\377\377\377\0\0\0\0\0\0\10\0\0\0\0\10\0\0\0\0\0\0\0\0\0\0\0\0"..., 256, 0, NULL, 0) = 256
select(1024, [3], NULL, NULL, {120, 0}) = 1 (in [3], left {119, 979635})
recvfrom(3, "\0\0\0,\0\0\0\0\0\0\10\360\0\0\10\0\0\0\0\0\0\0\0\n\0\0\0\0\0\0\0\0"..., 256, 0, NULL, NULL) = 256
connect(4, {sa_family=AF_FILE, path="/tmp/netpe62HGNM"}, 110) = 0
rt_sigaction(SIGALRM, {0x403171, [ALRM], SA_RESTORER|SA_INTERRUPT, 0x7f691f026af0}, NULL, 8) = 0
alarm(10)                               = 0
sendto(4, "netperf\0netperf\0netperf\0netperf\0"..., 2048, 0, NULL, 0) = -1 EMSGSIZE (Message too long)
dup(2)                                  = 5
fcntl(5, F_GETFL)                       = 0x8002 (flags O_RDWR|O_LARGEFILE)
fstat(5, {st_mode=S_IFCHR|0600, st_rdev=makedev(136, 3), ...}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f691fa18000
lseek(5, 0, SEEK_CUR)                   = -1 ESPIPE (Illegal seek)
write(5, "dg_send: data send error: Messag"..., 43dg_send: data send error: Message too long
) = 43
close(5)                                = 0
munmap(0x7f691fa18000, 4096)            = 0
exit_group(1)                           = ?

I guess the SO_SNDBUF/SO_RCVBUF limits are a bit too low ?

Tried this on an old kernel as well.

Linux edumazet-glaptop 2.6.38-13-generic #57~lucid1-Ubuntu SMP Tue Mar 6 20:05:46 UTC 2012 x86_64 GNU/Linux
