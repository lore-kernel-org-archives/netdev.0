From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Thu, 17 Nov 2016 15:08:58 -0800
Message-ID: <d7d209a8-6142-2599-3303-19640d340b97@hpe.com>
References: <20140903165943.372b897b@redhat.com>
 <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
 <20161116131609.4e5726b4@redhat.com>
 <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
 <20161116234022.2bad179b@redhat.com>
 <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117091638.5fab8494@redhat.com>
 <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117144248.23500001@redhat.com>
 <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117155753.17b76f5a@redhat.com>
 <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117193021.580589ae@redhat.com>
 <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
 <20161117221941.3b525181@redhat.com>
 <1479419042.8455.280.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3426.houston.hpe.com ([15.241.140.75]:48095 "EHLO
        g4t3426.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751590AbcKQXJB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 18:09:01 -0500
In-Reply-To: <1479419042.8455.280.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/17/2016 01:44 PM, Eric Dumazet wrote:
> because netperf sends the same message
> over and over...

Well, sort of, by default.  That can be altered to a degree.

The global -F option should cause netperf to fill the buffers in its 
send ring with data from the specified file.  The number of buffers in 
the send ring can be controlled via the global -W option.  The number of 
elements in the ring will default to one more than the initial SO_SNDBUF 
size divided by the send size.

raj@tardy:~/netperf2_trunk$ strace -v -o /tmp/netperf.strace src/netperf 
-F src/nettest_omni.c -t UDP_STREAM -l 1 -- -m 1472

...

socket(PF_INET, SOCK_DGRAM, IPPROTO_UDP) = 4
getsockopt(4, SOL_SOCKET, SO_SNDBUF, [212992], [4]) = 0
getsockopt(4, SOL_SOCKET, SO_RCVBUF, [212992], [4]) = 0
setsockopt(4, SOL_SOCKET, SO_REUSEADDR, [1], 4) = 0
bind(4, {sa_family=AF_INET, sin_port=htons(0), 
sin_addr=inet_addr("0.0.0.0")}, 16) = 0
setsockopt(4, SOL_SOCKET, SO_DONTROUTE, [1], 4) = 0
setsockopt(4, SOL_IP, IP_RECVERR, [1], 4) = 0
open("src/nettest_omni.c", O_RDONLY)    = 5
fstat(5, {st_dev=makedev(8, 2), st_ino=82075297, st_mode=S_IFREG|0664, 
st_nlink=1, st_uid=1000, st_gid=1000, st_blksize=4096, st_blocks=456, 
st_size=230027, st_atime=2016/11/16-09:49:29, 
st_mtime=2016/11/16-09:49:24, st_ctime=2016/11/16-09:49:24}) = 0
mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) 
= 0x7f3099f62000
read(5, "#ifdef HAVE_CONFIG_H\n#include <c"..., 4096) = 4096
read(5, "_INTEGER *intvl_two_ptr = &intvl"..., 4096) = 4096
read(5, "interval_count = interval_burst;"..., 4096) = 4096
read(5, ";\n\n/* these will control the wid"..., 4096) = 4096
read(5, "\n  LOCAL_SECURITY_ENABLED_NUM,\n "..., 4096) = 4096
read(5, "      &dwBytes,  \n              "..., 4096) = 4096

...

rt_sigaction(SIGALRM, {0x402ea6, [ALRM], SA_RESTORER|SA_INTERRUPT, 
0x7f30994a7cb0}, NULL, 8) = 0
rt_sigaction(SIGINT, {0x402ea6, [INT], SA_RESTORER|SA_INTERRUPT, 
0x7f30994a7cb0}, NULL, 8) = 0
alarm(1)                                = 0
sendto(4, "#ifdef HAVE_CONFIG_H\n#include <c"..., 1472, 0, 
{sa_family=AF_INET, sin_port=htons(58088), 
sin_addr=inet_addr("127.0.0.1")}, 16) = 1472
sendto(4, " used\\n\\\n    -m local,remote   S"..., 1472, 0, 
{sa_family=AF_INET, sin_port=htons(58088), 
sin_addr=inet_addr("127.0.0.1")}, 16) = 1472
sendto(4, " do here but clear the legacy fl"..., 1472, 0, 
{sa_family=AF_INET, sin_port=htons(58088), 
sin_addr=inet_addr("127.0.0.1")}, 16) = 1472
sendto(4, "e before we scan the test-specif"..., 1472, 0, 
{sa_family=AF_INET, sin_port=htons(58088), 
sin_addr=inet_addr("127.0.0.1")}, 16) = 1472
sendto(4, "\n\n\tfprintf(where,\n\t\ttput_fmt_1_l"..., 1472, 0, 
{sa_family=AF_INET, sin_port=htons(58088), 
sin_addr=inet_addr("127.0.0.1")}, 16) = 1472

Of course, it will continue to send the same messages from the send_ring 
over and over instead of putting different data into the buffers each 
time, but if one has a sufficiently large -W option specified...
happy benchmarking,

rick jones
