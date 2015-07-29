From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] arp: filter NOARP neighbours for SIOCGARP
Date: Wed, 29 Jul 2015 11:15:51 +0200
Message-ID: <1438161351.20182.73.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1437989630.20182.35.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150728.234147.1087098759056655521.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, valas@google.com, willemb@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:36746 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751328AbbG2JPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 05:15:55 -0400
Received: by wicgb10 with SMTP id gb10so191063141wic.1
        for <netdev@vger.kernel.org>; Wed, 29 Jul 2015 02:15:54 -0700 (PDT)
In-Reply-To: <20150728.234147.1087098759056655521.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-07-28 at 23:41 -0700, David Miller wrote:

> Applied, thanks Eric.
Thanks David

Note that IPv6 is completely broken after 'arp off' sequence.

ND destination MAC are a copy of eth0 MAC address, instead of the required multicast.

lpaa23:~# ip link set dev eth0 arp off
lpaa23:~# ping6 4444::555:0027
PING 4444::555:0027(4444::555:27) 56 data bytes
02:05:13.742684 00:1a:11:c3:0d:7f > 00:1a:11:c3:0d:7f, ethertype IPv6 (0x86dd), length 118: 4444::555:23 > 4444::555:27: ICMP6, echo request, seq 1, length 64
02:05:14.742200 00:1a:11:c3:0d:7f > 00:1a:11:c3:0d:7f, ethertype IPv6 (0x86dd), length 118: 4444::555:23 > 4444::555:27: ICMP6, echo request, seq 2, length 64
^C
--- 4444::555:0027 ping statistics ---
2 packets transmitted, 0 received, 100% packet loss, time 999ms

lpaa23:~# ip link set dev eth0 arp on 

lpaa23:~# ip -6 neigh sh dev eth0
fe80::21a:11ff:fec3:d45 lladdr 00:1a:11:c3:0d:45 STALE
4444::555:26  FAILED
4444::555:25  FAILED

lpaa23:~# ping6 4444::555:0027
PING 4444::555:0027(4444::555:27) 56 data bytes
02:12:15.698654 00:1a:11:c3:0d:7f > 00:1a:11:c3:0d:7f, ethertype IPv6 (0x86dd), length 118: 4444::555:23 > 4444::555:27: ICMP6, echo request, seq 1, length 64
02:12:16.698249 00:1a:11:c3:0d:7f > 00:1a:11:c3:0d:7f, ethertype IPv6 (0x86dd), length 118: 4444::555:23 > 4444::555:27: ICMP6, echo request, seq 2, length 64
02:12:17.698224 00:1a:11:c3:0d:7f > 00:1a:11:c3:0d:7f, ethertype IPv6 (0x86dd), length 118: 4444::555:23 > 4444::555:27: ICMP6, echo request, seq 3, length 64
^C
--- 4444::555:0027 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 1999ms

lpaa23:~# ip -6 neigh flush dev eth0

lpaa23:~# ip -6 neigh sh dev eth0
4444::555:24  FAILED
4444::555:28  FAILED
fe80::21a:11ff:fec3:d45  FAILED
4444::555:26  FAILED
4444::555:25  FAILED

Oh well...
