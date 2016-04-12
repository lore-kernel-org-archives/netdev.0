From: =?UTF-8?B?5ZCJ6Jek6Iux5piO?= <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: Issue with ping source address display
Date: Wed, 13 Apr 2016 07:59:43 +0900
Message-ID: <CAPA1RqDznRLYNBLCv4CLHY4ge=Q0fuFdC=VPg9947ZciMbjdkg@mail.gmail.com>
References: <570D35CF.9070006@orlandi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>
To: Daniele Orlandi <daniele@orlandi.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35739 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758833AbcDLW7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 18:59:44 -0400
Received: by mail-oi0-f51.google.com with SMTP id p188so41560220oih.2
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 15:59:43 -0700 (PDT)
In-Reply-To: <570D35CF.9070006@orlandi.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

2016-04-13 2:52 GMT+09:00 Daniele Orlandi <daniele@orlandi.com>:
>
> Hello,
>
> More than one year ago I posted the following message but it hasn't
> received a reply, now I've been stung by a similar issue, you may want
> to investigate:
>
>
> I noticed that when ping receives ICMP messages from different sources
> the first IP address is always used and displayed:
>
>
> vihai@seviolab:~$ ping -V
> ping utility, iputils-s20121221
>
> This is a (simulated) flapping route:
>
> vihai@seviolab:~$ ping 10.254.10.140
> PING 10.254.10.140 (10.254.10.140) 56(84) bytes of data.
> From 192.168.1.1 icmp_seq=1 Destination Host Unreachable
> From 192.168.1.1 icmp_seq=2 Destination Host Unreachable
> From 192.168.1.1 icmp_seq=3 Destination Host Unreachable
> 64 bytes from 192.168.1.1: icmp_seq=4 ttl=61 time=24.7 ms
> 64 bytes from 192.168.1.1: icmp_seq=5 ttl=61 time=25.6 ms
> 64 bytes from 192.168.1.1: icmp_seq=6 ttl=61 time=69.6 ms
> From 192.168.1.1 icmp_seq=7 Destination Host Unreachable
> From 192.168.1.1 icmp_seq=8 Destination Host Unreachable
> From 192.168.1.1 icmp_seq=9 Destination Host Unreachable
> ^C
> --- 10.254.10.140 ping statistics ---
> 9 packets transmitted, 3 received, +6 errors, 66% packet loss, time 8001ms
> rtt min/avg/max/mdev = 24.797/40.061/69.692/20.955 ms
>
>
> The sources, however are different:
>
> vihai@seviolab:~$ sudo tcpdump -n icmp
> tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
> listening on eth0, link-type EN10MB (Ethernet), capture size 65535 bytes
> ^[OA^[OA^[OA17:09:55.932981 IP 192.168.1.21 > 10.254.10.140: ICMP echo
> request, id 9278, seq 1, length 64
> 17:09:55.933234 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
> unreachable, length 92
> 17:09:56.933169 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
> 9278, seq 2, length 64
> 17:09:56.933416 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
> unreachable, length 92
> 17:09:57.933160 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
> 9278, seq 3, length 64
> 17:09:57.933404 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
> unreachable, length 92
> 17:09:58.933163 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
> 9278, seq 4, length 64
> 17:09:58.957939 IP 10.254.10.140 > 192.168.1.21: ICMP echo reply, id
> 9278, seq 4, length 64
> 17:09:59.935050 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
> 9278, seq 5, length 64
> 17:09:59.960724 IP 10.254.10.140 > 192.168.1.21: ICMP echo reply, id
> 9278, seq 5, length 64
> 17:10:00.936177 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
> 9278, seq 6, length 64
> 17:10:01.005849 IP 10.254.10.140 > 192.168.1.21: ICMP echo reply, id
> 9278, seq 6, length 64
> 17:10:01.936313 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
> 9278, seq 7, length 64
> 17:10:01.936626 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
> unreachable, length 92
> 17:10:02.935321 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
> 9278, seq 8, length 64
> 17:10:02.935591 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
> unreachable, length 92
> 17:10:03.934322 IP 192.168.1.21 > 10.254.10.140: ICMP echo request, id
> 9278, seq 9, length 64
> 17:10:03.934613 IP 192.168.1.1 > 192.168.1.21: ICMP host 10.254.10.140
> unreachable, length 92
>

Thank you for your report.  I'll try fixing it.

--yoshfuji

>
>
>
> Tried with a different ping implementation (RouterOS) and the behaviour
> seems correct:
>
> [vihai@SevioLab SW1] > ping 10.254.10.140
> HOST                                     SIZE TTL TIME  STATUS
> 192.168.1.1                             84  64 0ms   host unreachable
> 192.168.1.1                             84  64 0ms   host unreachable
> 192.168.1.1                             84  64 0ms   host unreachable
> 10.254.10.140                           56  61 20ms
> 10.254.10.140                           56  61 46ms
> 10.254.10.140                           56  61 37ms
> 192.168.1.1                             84  64 0ms   host unreachable
> 192.168.1.1                             84  64 0ms   host unreachable
> 192.168.1.1                             84  64 0ms   host unreachable
>     sent=9 received=3 packet-loss=66% min-rtt=20ms avg-rtt=34ms max-rtt=46ms
>
>
> Recently I was pinging with IPv6, a router in between filtered the
> packet, however the shown source address was not the right one:
>
> root@monitor:~# ping6 -i 0.2 www.google.com
> PING www.google.com(mil01s25-in-x04.1e100.net) 56 data bytes
> From mil01s25-in-x04.1e100.net icmp_seq=1 Destination unreachable: No route
> From mil01s25-in-x04.1e100.net icmp_seq=2 Destination unreachable: No route
> From mil01s25-in-x04.1e100.net icmp_seq=3 Destination unreachable: No route
>
> 19:33:19.589285 IP6 2a01:2d8:aca0:fce:944e:c8ff:fe4d:96de >
> mil01s25-in-x04.1e100.net: ICMP6, echo request, seq 1, length 64
> 19:33:19.611666 IP6 mix-br2.intercom.it >
> 2a01:2d8:aca0:fce:944e:c8ff:fe4d:96de: ICMP6, destination unreachable,
> unreachable route mil01s25-in-x04.1e100.net, length 112
>
>
> Bye,
>
