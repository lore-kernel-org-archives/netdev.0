From: Naohiro Ooiwa <nooiwa@miraclelinux.com>
Subject: ping6 is sent out from wrong interface
Date: Fri, 20 Jun 2008 10:42:53 +0900
Message-ID: <485B0B1D.5000603@miraclelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
To: netdev@vger.kernel.org, usagi-users@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.miraclelinux.com ([219.118.163.66]:29914 "EHLO
	mail.miraclelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbYFTCO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 22:14:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I configured the IPv6 global address for two interfaces,
and sent the ping with "-I <eth1 address>" to the "ff02::1".

    # ifconfig eth0 add 2001:2c0:418:1::2/64
    # ifconfig eth1 add 2001:2c0:418:2::2/64
    # ping6 -I2001:2c0:418:2::2 ff02::1

    # /usr/sbin/tcpdump -ieth1 icmp6 -v -e
    tcpdump: listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
    0 packets captured
    0 packets received by filter
    0 packets dropped by kernel

The ping packets weren't sent from "eth1",
so I captured the packets on the "eth0" by tcpdump.

    # /usr/sbin/tcpdump -ieth0 icmp6 -v -e
    tcpdump: listening on eth0, link-type EN10MB (Ethernet), capture size 96 bytes
    18:16:53.900751 00:19:d1:19:23:af (oui Unknown) > 33:33:00:00:00:01 (oui Unknown), ethertype IPv6 (0x86dd), length
118: (hlim 64, next-header: ICMPv6 (58), length: 64) 2001:2c0:418:2::2 > ff02::1: ICMP6, echo request, length 64, seq 190
    18:16:53.957145 00:1d:09:7a:91:19 (oui Unknown) > 33:33:00:00:00:02 (oui Unknown), ethertype IPv6 (0x86dd), length
70: (hlim 255, next-header: ICMPv6 (58), length: 16) fe80::21d:9ff:fe7a:9119 > ff02::2: [icmp6 sum ok] ICMP6, router
solicitation, length 16
              source link-address option (1), length 8 (1): 00:1d:09:7a:91:19
    ::::::

The ping packets were sent out from "eth0"(00:19:d1:19:23:af),
but IPv6 address was "eth1"(2001:2c0:418:2::2).
Why is interface "eth0".  Isn't it bug ?

The following is additional information.

    # ifconfig eth0
    eth0      Link encap:Ethernet  HWaddr 00:19:D1:19:23:AF
              inet addr:10.1.0.161  Bcast:10.1.255.255  Mask:255.255.0.0
              inet6 addr: 2001:2c0:418:1::1/64 Scope:Global
              inet6 addr: fe80::219:d1ff:fe19:23af/64 Scope:Link
              ::::::
    # ifconfig eth1
    eth1      Link encap:Ethernet  HWaddr 00:10:18:0E:0C:B4
              inet addr:172.16.255.200  Bcast:172.16.255.255  Mask:255.255.0.0
              inet6 addr: 2001:2c0:418:2::2/64 Scope:Global
              inet6 addr: fe80::210:18ff:fe0e:cb4/64 Scope:Link
              ::::::

    # route -A inet6
    Kernel IPv6 routing table
    Destination            Next Hop Flags Metric Ref    Use Iface
    2001:2c0:418:1::/64    *        U     256    0        0 eth0
    2001:2c0:418:2::/64    *        U     256    0        0 eth1
    fe80::/64              *        U     256    0        0 eth0
    fe80::/64              *        U     256    0        0 eth1
    ::::::
    2001:2c0:418:1::1/128  *        U     0      8        1 lo
    2001:2c0:418:2::2/128  *        U     0      5        1 lo
    ::::::
    ff00::/8               *        U     256    0        0 eth0
    ff00::/8               *        U     256    0        0 eth1
    #

The version used are following:

    # uname -r -m
    2.6.24.7-92.fc8 i686
    # ping6 -V
    ping6 utility, iputils-sss20070202


Regards,
Naohiro Ooiwa

