From: Sergio Correia <lists@uece.net>
Subject: Re: WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x4f/0x110()
Date: Tue, 22 May 2012 11:47:19 -0300
Message-ID: <CAJyhjX2f_XFgVZpS1hLy5CWKY7eYA5MzQSHsfRgc40-2Rxztkw@mail.gmail.com>
References: <CAJyhjX22Vna=TwuhD-FqyoXEd9D8wq_VdHbAAWwmqO1hZ34FRA@mail.gmail.com>
 <CAJyhjX1VKQpAbqkxnWFNrRSVBuSRYaNQSUXYWqYfoE0GnmVokQ@mail.gmail.com> <1337697203.3361.190.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:47645 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755162Ab2EVOrl convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 May 2012 10:47:41 -0400
Received: by pbbrp8 with SMTP id rp8so8483426pbb.19
        for <netdev@vger.kernel.org>; Tue, 22 May 2012 07:47:40 -0700 (PDT)
In-Reply-To: <1337697203.3361.190.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Tue, May 22, 2012 at 11:33 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
> On Tue, 2012-05-22 at 10:57 -0300, Sergio Correia wrote:
>> On Tue, May 22, 2012 at 2:43 AM, Sergio Correia <lists@uece.net> wro=
te:
>> > So far it has happened only once.
>> > Last commit is 471368557a734c6c486ee757952c902b36e7fd01.
>> >
>> >
>> > [ 3726.624387] ------------[ cut here ]------------
>> > [ 3726.624398] WARNING: at net/ipv4/tcp.c:1301 tcp_cleanup_rbuf+0x=
4f/0x110()
>> > [ 3726.624400] Hardware name: N53SV
>> > [ 3726.624402] cleanup rbuf bug: copied A4D1F126 seq A4D1F126 rcvn=
xt A4D1F126
>> > [ 3726.624404] Modules linked in:
>> > [ 3726.624407] Pid: 1416, comm: transmission-gt Not tainted 3.4.0-=
git+ #52
>> > [ 3726.624409] Call Trace:
>> > [ 3726.624415] =A0[<ffffffff81035eba>] warn_slowpath_common+0x7a/0=
xb0
>> > [ 3726.624419] =A0[<ffffffff81035f91>] warn_slowpath_fmt+0x41/0x50
>> > [ 3726.624507] =A0[<ffffffff81aa57a5>] ? sub_preempt_count+0x65/0x=
c0
>> > [ 3726.624510] =A0[<ffffffff819101cf>] tcp_cleanup_rbuf+0x4f/0x110
>> > [ 3726.624514] =A0[<ffffffff819112b7>] tcp_recvmsg+0x637/0xa60
>> > [ 3726.624518] =A0[<ffffffff81849310>] ? release_sock+0xe0/0x110
>> > [ 3726.624522] =A0[<ffffffff81934a34>] inet_recvmsg+0x94/0xc0
>> > [ 3726.624534] =A0[<ffffffff81844792>] sock_aio_read.part.8+0x142/=
0x170
>> > [ 3726.624537] =A0[<ffffffff818447c0>] ? sock_aio_read.part.8+0x17=
0/0x170
>> > [ 3726.624540] =A0[<ffffffff818447e1>] sock_aio_read+0x21/0x30
>> > [ 3726.624544] =A0[<ffffffff81124b0a>] do_sync_readv_writev+0xca/0=
x110
>> > [ 3726.624548] =A0[<ffffffff8140f582>] ? security_file_permission+=
0x92/0xb0
>> > [ 3726.624552] =A0[<ffffffff8112425c>] ? rw_verify_area+0x5c/0xe0
>> > [ 3726.624555] =A0[<ffffffff81124de6>] do_readv_writev+0xd6/0x1e0
>> > [ 3726.624558] =A0[<ffffffff8184336b>] ? sock_do_ioctl+0x2b/0x70
>> > [ 3726.624562] =A0[<ffffffff81135abf>] ? do_vfs_ioctl+0x8f/0x530
>> > [ 3726.624566] =A0[<ffffffff8141278f>] ? file_has_perm+0x8f/0xa0
>> > [ 3726.624569] =A0[<ffffffff81124f7d>] vfs_readv+0x2d/0x50
>> > [ 3726.624572] =A0[<ffffffff81124fe5>] sys_readv+0x45/0xb0
>> > [ 3726.624575] =A0[<ffffffff81aa9062>] system_call_fastpath+0x16/0=
x1b
>> > [ 3726.624578] ---[ end trace 6dc5d813929e5e6f ]---
>>
>> Checked this morning, and my dmesg now is basically composed of this
>> warning over and over and over.
>
> Is it wifi adapter ?
>

Yes, it's an Atheros AR9285 adapter.
This morning I did a make mrproper before rebuilding the kernel
(should I always do that?), but the warning has just appeared again.

> Please send "netstat -s" output
>

netstat -s
Ip:
    49826 total packets received
    3 with invalid addresses
    0 forwarded
    0 incoming packets discarded
    49771 incoming packets delivered
    36344 requests sent out
Icmp:
    129 ICMP messages received
    1 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 129
    156 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 156
IcmpMsg:
        InType3: 129
        OutType3: 156
Tcp:
    1150 active connections openings
    42 passive connection openings
    63 failed connection attempts
    45 connection resets received
    29 connections established
    25457 segments received
    23088 segments send out
    689 segments retransmited
    0 bad segments received.
    347 resets sent
Udp:
    23927 packets received
    155 packets to unknown port received.
    0 packet receive errors
    12411 packets sent
    0 receive buffer errors
    0 send buffer errors
UdpLite:
TcpExt:
    19 invalid SYN cookies received
    1 resets received for embryonic SYN_RECV sockets
    122 TCP sockets finished time wait in fast timer
    668 delayed acks sent
    Quick ack mode was activated 228 times
    2 packets directly queued to recvmsg prequeue.
    2 bytes directly received in process context from prequeue
    10825 packet headers predicted
    2914 acknowledgments not containing data payload received
    1355 predicted acknowledgments
    3 times recovered from packet loss by selective acknowledgements
    1 congestion windows recovered without slow start by DSACK
    36 congestion windows recovered without slow start after partial ac=
k
    3 fast retransmits
    229 other TCP timeouts
    1 SACK retransmits failed
    441 DSACKs sent for old packets
    11 DSACKs sent for out of order packets
    31 DSACKs received
    35 connections reset due to unexpected data
    32 connections reset due to early user close
    3 connections aborted due to timeout
    TCPDSACKIgnoredNoUndo: 6
    TCPSackShiftFallback: 11
    TCPRcvCoalesce: 8467
IpExt:
    OutMcastPkts: 13
    InBcastPkts: 271
    OutBcastPkts: 184
    InOctets: 53951318
    OutOctets: 5022932
    OutMcastOctets: 2091
    InBcastOctets: 40466
    OutBcastOctets: 32946
