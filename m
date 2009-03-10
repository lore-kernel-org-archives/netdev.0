From: Rick Jones <rick.jones2@hp.com>
Subject: Re: TCP rx window autotuning harmful at LAN context
Date: Tue, 10 Mar 2009 10:20:12 -0700
Message-ID: <49B6A14C.9070704@hp.com>
References: <20090309112521.GB37984@bts.sk>	<1e41a3230903091101u536a3b3bv7f0dd9da6891781e@mail.gmail.com>	<20090309200505.GA58375@bts.sk>	<20090309.170927.130334650.davem@davemloft.net>	<49B5B5A7.8090502@hp.com> <1e41a3230903092055q2317e0cas3721d18fb4cef062@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, md@bts.sk,
	netdev@vger.kernel.org
To: John Heffner <johnwheffner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:16857 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755551AbZCJRUS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2009 13:20:18 -0400
In-Reply-To: <1e41a3230903092055q2317e0cas3721d18fb4cef062@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> (Pretty sure we went over this already, but once more..) 

Sometimes I am but dense north by northwest, but I am also occasionally simply 
dense regardless of the direction :)

> The receiver does not size to twice cwnd.  It sizes to twice the amount of
> data that the application read in one RTT.  In the common case of a path 
> bottleneck and a receiving application that always keeps up, this equals
> 2*cwnd, but the distinction is very important to understanding its behavior in
> other cases.
> 
> In your test where you limit sndbuf to 256k, you will find that you
> did not fill up the bottleneck queues, and you did not get a
> significantly increased RTT, which are the negative effects we want to
> avoid.  The large receive window caused no trouble at all.

What is the definition of "significantly" here?

With my 256K capped SO_SNDBUF ping seems to report like this:

[root@dl5855 ~]# ping sut42
PING sut42.west (10.208.0.45) 56(84) bytes of data.
64 bytes from sut42.west (10.208.0.45): icmp_seq=1 ttl=64 time=1.58 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=2 ttl=64 time=0.126 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=3 ttl=64 time=0.103 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=4 ttl=64 time=0.102 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=5 ttl=64 time=0.104 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=6 ttl=64 time=0.100 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=7 ttl=64 time=0.140 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=8 ttl=64 time=0.103 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=9 ttl=64 time=11.3 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=10 ttl=64 time=10.3 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=11 ttl=64 time=7.42 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=12 ttl=64 time=4.51 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=13 ttl=64 time=1.56 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=14 ttl=64 time=4.47 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=15 ttl=64 time=4.63 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=16 ttl=64 time=1.66 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=17 ttl=64 time=7.65 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=18 ttl=64 time=4.73 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=19 ttl=64 time=0.135 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=20 ttl=64 time=0.116 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=21 ttl=64 time=0.102 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=22 ttl=64 time=0.102 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=23 ttl=64 time=0.098 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=24 ttl=64 time=0.104 ms

FWIW, when I uncap the SO_SNDBUF, the RTTs start to look like this instead:

[root@dl5855 ~]# ping sut42
PING sut42.west (10.208.0.45) 56(84) bytes of data.
64 bytes from sut42.west (10.208.0.45): icmp_seq=1 ttl=64 time=0.183 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=2 ttl=64 time=0.107 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=3 ttl=64 time=0.100 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=4 ttl=64 time=0.117 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=5 ttl=64 time=0.103 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=6 ttl=64 time=0.099 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=7 ttl=64 time=0.123 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=8 ttl=64 time=26.2 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=9 ttl=64 time=24.3 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=10 ttl=64 time=26.3 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=11 ttl=64 time=26.4 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=12 ttl=64 time=26.3 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=13 ttl=64 time=26.2 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=14 ttl=64 time=26.6 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=15 ttl=64 time=26.2 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=16 ttl=64 time=26.5 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=17 ttl=64 time=26.3 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=18 ttl=64 time=0.126 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=19 ttl=64 time=0.119 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=20 ttl=64 time=0.120 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=21 ttl=64 time=0.097 ms

And then when I cap both sides to 64K requested/128K and still get link-rate the 
pings look like:

[root@dl5855 ~]# ping sut42
PING sut42.west (10.208.0.45) 56(84) bytes of data.
64 bytes from sut42.west (10.208.0.45): icmp_seq=1 ttl=64 time=0.161 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=2 ttl=64 time=0.104 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=3 ttl=64 time=0.103 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=4 ttl=64 time=0.101 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=5 ttl=64 time=0.106 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=6 ttl=64 time=0.102 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=7 ttl=64 time=0.753 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=8 ttl=64 time=0.594 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=9 ttl=64 time=0.789 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=10 ttl=64 time=0.566 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=11 ttl=64 time=0.587 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=12 ttl=64 time=0.635 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=13 ttl=64 time=0.729 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=14 ttl=64 time=0.613 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=15 ttl=64 time=0.609 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=16 ttl=64 time=0.655 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=17 ttl=64 time=0.152 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=18 ttl=64 time=0.106 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=19 ttl=64 time=0.100 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=20 ttl=64 time=0.106 ms
64 bytes from sut42.west (10.208.0.45): icmp_seq=21 ttl=64 time=0.122 ms

None of the above "absolves" the sender of course, but I still get wrapped around 
the axle of handing so much rope to senders when we know 99 times out of ten they 
are going to hang themselves with it.

rick jones

Netperf cannot tell me bytes received per RTT, but it can tell me the average 
bytes per recv() call.  I'm not sure if that is a sufficient approximation but 
here are those three netperf runs re-run with remote_bytes_per_recv added to the 
output:

[root@dl5855 ~]# netperf -t omni -H sut42 -- -k foo -s 64K -S 64K
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to sut42.west (10.208.0.45) port 
0 AF_INET
THROUGHPUT=941.07
LSS_SIZE_REQ=65536
LSS_SIZE=131072
LSS_SIZE_END=131072
RSR_SIZE_REQ=65536
RSR_SIZE=131072
RSR_SIZE_END=131072
REMOTE_BYTES_PER_RECV=8178.43
[root@dl5855 ~]# netperf -t omni -H sut42 -- -k foo -s 128K
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to sut42.west (10.208.0.45) port 
0 AF_INET
THROUGHPUT=941.31
LSS_SIZE_REQ=131072
LSS_SIZE=262142
LSS_SIZE_END=262142
RSR_SIZE_REQ=-1
RSR_SIZE=87380
RSR_SIZE_END=4194304
REMOTE_BYTES_PER_RECV=8005.97
[root@dl5855 ~]# netperf -t omni -H sut42 -- -k foo
OMNI TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to sut42.west (10.208.0.45) port 
0 AF_INET
THROUGHPUT=941.33
LSS_SIZE_REQ=-1
LSS_SIZE=16384
LSS_SIZE_END=4194304
RSR_SIZE_REQ=-1
RSR_SIZE=87380
RSR_SIZE_END=4194304
REMOTE_BYTES_PER_RECV=8055.89
