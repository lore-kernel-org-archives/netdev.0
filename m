From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH] net: ipv6: Make address flushing on ifdown optional -
 v3
Date: Thu, 12 Feb 2015 17:57:36 +0100
Message-ID: <54DCDB80.9090601@6wind.com>
References: <1423715261-53131-1-git-send-email-dsahern@gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hannes Frederic Sowa <hannes@redhat.com>
To: David Ahern <dsahern@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:36660 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750935AbbBLQ5j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Feb 2015 11:57:39 -0500
Received: by mail-wi0-f178.google.com with SMTP id em10so5895459wid.5
        for <netdev@vger.kernel.org>; Thu, 12 Feb 2015 08:57:38 -0800 (PST)
In-Reply-To: <1423715261-53131-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 12/02/2015 05:27, David Ahern a =C3=A9crit :
> Currently, all ipv6 addresses are flushed when the interface is confi=
gured
> down, even static address:
>
[snip]
>
> [root@f20 ~]# echo 0 > /proc/sys/net/ipv6/conf/eth1/flush_addr_on_dow=
n
> [root@f20 ~]# ip -6 addr add dev eth1 2000:11:1:1::1/64
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN g=
roup default qlen 1000
>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>      inet6 2000:11:1:1::1/64 scope global tentative
>         valid_lft forever preferred_lft forever
> [root@f20 ~]#  ip link set dev eth1 up
> [root@f20 ~]#  ip link set dev eth1 down
> [root@f20 ~]# ip addr show dev eth1
> 3: eth1: <BROADCAST,MULTICAST> mtu 1500 qdisc pfifo_fast state DOWN g=
roup default qlen 1000
>      link/ether 02:04:11:22:33:01 brd ff:ff:ff:ff:ff:ff
>      inet6 2000:11:1:1::1/64 scope global
>         valid_lft forever preferred_lft forever
>      inet6 fe80::4:11ff:fe22:3301/64 scope link
>         valid_lft forever preferred_lft forever
Can you show an output of 'ip -6 route list table local' and 'ip -6 rou=
te' ?
