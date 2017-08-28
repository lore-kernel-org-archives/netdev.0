From: Tariq Toukan <tariqt@mellanox.com>
Subject: IPv6 loopback issue report
Date: Mon, 28 Aug 2017 17:48:49 +0300
Message-ID: <464e900f-c256-4d22-6a83-a3aea0fca8bc@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ranro@mellanox.com, guye@mellanox.com,
        Eran Ben Elisha <eranbe@mellanox.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0048.outbound.protection.outlook.com ([104.47.2.48]:37792
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751184AbdH1Os7 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 10:48:59 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

We encountered the following issue in our regression tests over net-next 
branch.
IPv6 loopback ping fails, while it works for IPv4.

Reproduces with all NICs, doesn't seem to be a driver issue.

Example:

# ifconfig ens8
ens8: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
         inet 11.141.16.6  netmask 255.255.0.0  broadcast 11.141.255.255
         inet6 fe80::7efe:90ff:fecb:7502  prefixlen 64  scopeid 0x20<link>
         ether 7c:fe:90:cb:75:02  txqueuelen 1000  (Ethernet)
         RX packets 12  bytes 1164 (1.1 KiB)
         RX errors 0  dropped 0  overruns 0  frame 0
         TX packets 30  bytes 2484 (2.4 KiB)
         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

# ping -c 3 11.141.16.6
PING 11.141.16.6 (11.141.16.6) 56(84) bytes of data.
64 bytes from 11.141.16.6: icmp_seq=1 ttl=64 time=0.017 ms
64 bytes from 11.141.16.6: icmp_seq=2 ttl=64 time=0.014 ms
64 bytes from 11.141.16.6: icmp_seq=3 ttl=64 time=0.014 ms

--- 11.141.16.6 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2025ms
rtt min/avg/max/mdev = 0.014/0.015/0.017/0.001 ms

#  /bin/ping6 -c 3 fe80::7efe:90ff:fecb:7502%ens8
PING fe80::7efe:90ff:fecb:7502%ens8(fe80::7efe:90ff:fecb:7502) 56 data bytes

--- fe80::7efe:90ff:fecb:7502%ens8 ping statistics ---
3 packets transmitted, 0 received, 100% packet loss, time 2043ms

Regards,
Tariq Toukan
