From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: VLAN filtering/VLAN aware bridge problems
Date: Thu, 29 Aug 2013 16:45:23 -0400
Message-ID: <521FB2E3.6060508@redhat.com>
References: <521F4393.1020907@profihost.ag>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64685 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756218Ab3H2Upc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 16:45:32 -0400
In-Reply-To: <521F4393.1020907@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/29/2013 08:50 AM, Stefan Priebe - Profihost AG wrote:
> Hello,
>
> currently i'm running vanilla 3.8.8 kernel with some tap devices using
> VLANs on top of a bridge on top of a bond.
>
> This works fine and everything is great.
>
> Now i started to test 3.10.9 and all my VLANs stopped working no matter
> i disable or enable CONFIG_BRIDGE_VLAN_FILTERING.

Just enabling config option doesn't turn on the filtering behavior.

>
> The packets never reach the TAP device.
>
> Here is an output of ip a l (vlan 3021):

Can you provide output of brctl show?

>
> ip a l
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN
>      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>      inet 127.0.0.1/8 scope host lo
>         valid_lft forever preferred_lft forever
>      inet6 ::1/128 scope host
>         valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,PROMISC,SLAVE,UP,LOWER_UP> mtu 1500 qdisc
> mq master bond0 state UP qlen 1000
>      link/ether 00:25:90:84:de:a8 brd ff:ff:ff:ff:ff:ff
> 3: eth4: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 9000 qdisc mq
> master bond5 state UP qlen 10000
>      link/ether 90:e2:ba:33:45:0c brd ff:ff:ff:ff:ff:ff
> 4: eth1: <BROADCAST,MULTICAST,PROMISC,SLAVE,UP,LOWER_UP> mtu 1500 qdisc
> mq master bond0 state UP qlen 1000
>      link/ether 00:25:90:84:de:a8 brd ff:ff:ff:ff:ff:ff
> 5: eth2: <BROADCAST,MULTICAST,PROMISC,SLAVE,UP,LOWER_UP> mtu 1500 qdisc
> mq master bond1 state UP qlen 1000
>      link/ether 00:25:90:84:de:aa brd ff:ff:ff:ff:ff:ff
> 6: eth5: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 9000 qdisc mq
> master bond5 state UP qlen 10000
>      link/ether 90:e2:ba:33:45:0c brd ff:ff:ff:ff:ff:ff
> 7: eth3: <BROADCAST,MULTICAST,PROMISC,SLAVE,UP,LOWER_UP> mtu 1500 qdisc
> mq master bond1 state UP qlen 1000
>      link/ether 00:25:90:84:de:aa brd ff:ff:ff:ff:ff:ff
> 8: bond0: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc
> noqueue master vmbr0 state UP
>      link/ether 00:25:90:84:de:a8 brd ff:ff:ff:ff:ff:ff
>      inet6 fe80::225:90ff:fe84:dea8/64 scope link
>         valid_lft forever preferred_lft forever
> 9: bond1: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 1500 qdisc
> noqueue master vmbr1 state UP
>      link/ether 00:25:90:84:de:aa brd ff:ff:ff:ff:ff:ff
>      inet6 fe80::225:90ff:fe84:deaa/64 scope link
>         valid_lft forever preferred_lft forever
> 10: vmbr0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
> state UP
>      link/ether 00:25:90:84:de:a8 brd ff:ff:ff:ff:ff:ff
>      inet 178.250.9.30/25 brd 178.250.9.127 scope global vmbr0
>         valid_lft forever preferred_lft forever
>      inet6 fe80::225:90ff:fe84:dea8/64 scope link
>         valid_lft forever preferred_lft forever
> 11: vmbr1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
> state UP
>      link/ether 00:25:90:84:de:aa brd ff:ff:ff:ff:ff:ff
>      inet6 fe80::225:90ff:fe84:deaa/64 scope link
>         valid_lft forever preferred_lft forever
> 12: bond5: <BROADCAST,MULTICAST,MASTER,UP,LOWER_UP> mtu 9000 qdisc
> noqueue state UP
>      link/ether 90:e2:ba:33:45:0c brd ff:ff:ff:ff:ff:ff
>      inet 10.255.0.30/24 brd 10.255.0.255 scope global bond5
>         valid_lft forever preferred_lft forever
>      inet6 fe80::92e2:baff:fe33:450c/64 scope link
>         valid_lft forever preferred_lft forever
> 15: vmbr1.3020@vmbr1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
> noqueue master vmbr1v3020 state UP
>      link/ether 00:25:90:84:de:aa brd ff:ff:ff:ff:ff:ff
>      inet6 fe80::225:90ff:fe84:deaa/64 scope link
>         valid_lft forever preferred_lft forever
> 16: vmbr1v3020: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
> state UP
>      link/ether 00:25:90:84:de:aa brd ff:ff:ff:ff:ff:ff
>      inet6 fe80::f036:92ff:fe40:7224/64 scope link
>         valid_lft forever preferred_lft forever
> 19: tap320i0: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc
> htb master vmbr0 state UNKNOWN qlen 500
>      link/ether fe:fa:14:cc:75:b2 brd ff:ff:ff:ff:ff:ff
>      inet6 fe80::fcfa:14ff:fecc:75b2/64 scope link
>         valid_lft forever preferred_lft forever
> 20: tap320i1: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc
> htb master vmbr1v3021 state UNKNOWN qlen 500
>      link/ether 8a:f3:9b:47:c7:88 brd ff:ff:ff:ff:ff:ff
>      inet6 fe80::88f3:9bff:fe47:c788/64 scope link
>         valid_lft forever preferred_lft forever
> 21: vmbr1.3021@vmbr1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
> noqueue master vmbr1v3021 state UP
>      link/ether 00:25:90:84:de:aa brd ff:ff:ff:ff:ff:ff
>      inet6 fe80::225:90ff:fe84:deaa/64 scope link
>         valid_lft forever preferred_lft forever
> 22: vmbr1v3021: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue
> state UP
>      link/ether 00:25:90:84:de:aa brd ff:ff:ff:ff:ff:ff
>      inet6 fe80::9868:5eff:fe9d:bf56/64 scope link
>         valid_lft forever preferred_lft forever
>

I can only guess that the configuration based on the above data.  Can
you give a diagram of the config.

On the off chance that you are actually trying to configure vlan
filtering, can you give this patch a try (net-2.6 tree):

Author: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Date:   Tue Aug 20 17:10:18 2013 +0900

     bridge: Use the correct bit length for bitmap functions in the VLAN 
code

I don't think it made it to stable yet.

Thanks
-vlad

> Greets,
> Stefan
>
