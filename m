From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Whence a description of how to enable TCP FASTOPEN in a net-next
 kernel?
Date: Mon, 17 Dec 2012 14:56:00 -0800
Message-ID: <50CFA300.3040501@hp.com>
References: <50CF8E2A.5020201@hp.com> <1355781411.9380.12.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:24290 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752491Ab2LQW4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2012 17:56:01 -0500
In-Reply-To: <1355781411.9380.12.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2012 01:56 PM, Eric Dumazet wrote:
> On Mon, 2012-12-17 at 13:27 -0800, Rick Jones wrote:
>> [an explanation of what he'd done that hadn't worked]
>
> I guess you need to enable fastopen both for client and server :
>
> echo 3 >/proc/sys//net/ipv4/tcp_fastopen


Looks like I'm good now:

raj@tardy-ubuntu-1204:~$ cat /proc/sys/net/ipv4/tcp_fastopen
3
raj@tardy-ubuntu-1204:~$ sudo tcpdump -c 30 -i lo 'not port 12865'
[sudo] password for raj:
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on lo, link-type EN10MB (Ethernet), capture size 65535 bytes
14:28:43.536166 IP localhost.29105 > localhost.srvr: Flags [S], seq 
378007190, win 43690, options [mss 65495,sackOK,TS val 4294942097 ecr 
0,nop,wscale 7,Unknown Option 254f989], length 0
14:28:43.536191 IP localhost.srvr > localhost.29105: Flags [S.], seq 
2030806688, ack 378007191, win 43690, options [mss 65495,sackOK,TS val 
4294942097 ecr 4294942097,nop,wscale 7,Unknown Option 
254f989e73dc061f14d850e], length 0
14:28:43.537421 IP localhost.29105 > localhost.srvr: Flags [P.], seq 
1:2, ack 1, win 342, options [nop,nop,TS val 4294942098 ecr 4294942097], 
length 1
14:28:43.537445 IP localhost.srvr > localhost.29105: Flags [.], ack 2, 
win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.537525 IP localhost.srvr > localhost.29105: Flags [P.], seq 
1:2, ack 2, win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], 
length 1
14:28:43.537542 IP localhost.srvr > localhost.29105: Flags [F.], seq 2, 
ack 2, win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.537727 IP localhost.29105 > localhost.srvr: Flags [F.], seq 2, 
ack 3, win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.537741 IP localhost.srvr > localhost.29105: Flags [.], ack 3, 
win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.537895 IP localhost.29106 > localhost.srvr: Flags [S], seq 
1735077945:1735077946, win 43690, options [mss 65495,sackOK,TS val 
4294942098 ecr 0,nop,wscale 7,Unknown Option 254f989e73dc061f14d850e], 
length 1
14:28:43.537909 IP localhost.srvr > localhost.29106: Flags [S.], seq 
1983728126, ack 1735077947, win 43690, options [mss 65495,sackOK,TS val 
4294942098 ecr 4294942098,nop,wscale 7], length 0
14:28:43.537924 IP localhost.29106 > localhost.srvr: Flags [.], ack 1, 
win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.538014 IP localhost.srvr > localhost.29106: Flags [P.], seq 
1:2, ack 1, win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], 
length 1
14:28:43.538028 IP localhost.srvr > localhost.29106: Flags [F.], seq 2, 
ack 1, win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.538196 IP localhost.29106 > localhost.srvr: Flags [.], ack 2, 
win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.538288 IP localhost.29106 > localhost.srvr: Flags [F.], seq 1, 
ack 3, win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.538300 IP localhost.srvr > localhost.29106: Flags [.], ack 2, 
win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.538417 IP localhost.29107 > localhost.srvr: Flags [S], seq 
3902541042:3902541043, win 43690, options [mss 65495,sackOK,TS val 
4294942098 ecr 0,nop,wscale 7,Unknown Option 254f989e73dc061f14d850e], 
length 1
14:28:43.538431 IP localhost.srvr > localhost.29107: Flags [S.], seq 
941945820, ack 3902541044, win 43690, options [mss 65495,sackOK,TS val 
4294942098 ecr 4294942098,nop,wscale 7], length 0
14:28:43.538445 IP localhost.29107 > localhost.srvr: Flags [.], ack 1, 
win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.538518 IP localhost.srvr > localhost.29107: Flags [P.], seq 
1:2, ack 1, win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], 
length 1
14:28:43.538531 IP localhost.srvr > localhost.29107: Flags [F.], seq 2, 
ack 1, win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.538654 IP localhost.29107 > localhost.srvr: Flags [.], ack 2, 
win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.538730 IP localhost.29107 > localhost.srvr: Flags [F.], seq 1, 
ack 3, win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0
14:28:43.538742 IP localhost.srvr > localhost.29107: Flags [.], ack 2, 
win 342, options [nop,nop,TS val 4294942098 ecr 4294942098], length 0

in which case I suppose that means that netperf top-of-trunk does indeed 
have client and server side support for TCP_FASTOPEN.  Enabled via the 
test-specific -F option though in the loopback test (in a 1 VCPU VM) I 
don't see much of a difference (don't suppose I should really):

raj@tardy-ubuntu-1204:~/netperf2_trunk/src$ ./netperf -t TCP_CRR -l 30 
-i 30,3 -- -F -P ,12345
MIGRATED TCP Connect/Request/Response TEST from 0.0.0.0 (0.0.0.0) port 0 
AF_INET to localhost () port 12345 AF_INET : +/-2.500% @ 99% conf.  : demo
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       30.00    15909.07
16384  87380
raj@tardy-ubuntu-1204:~/netperf2_trunk/src$ ./netperf -t TCP_CRR -l 30 
-i 30,3 --  -P ,12345
MIGRATED TCP Connect/Request/Response TEST from 0.0.0.0 (0.0.0.0) port 0 
AF_INET to localhost () port 12345 AF_INET : +/-2.500% @ 99% conf.  : demo
Local /Remote
Socket Size   Request  Resp.   Elapsed  Trans.
Send   Recv   Size     Size    Time     Rate
bytes  Bytes  bytes    bytes   secs.    per sec

16384  87380  1        1       30.00    15574.37
16384  87380

happy benchmarking,

rick jones
