From: =?utf-8?B?0JDQu9C10LrRgdC10Lkg0JHQvtC70LTRi9GA0LXQsg==?=
        <devel-net-ne-vlezay80@yandex.ru>
Subject: iproute2 invalid argument mpls labels
Date: Tue, 15 Aug 2017 11:17:27 +0300
Message-ID: <77691502785047@web24j.yandex.ru>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward102o.mail.yandex.net ([37.140.190.182]:45328 "EHLO
        forward102o.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750994AbdHOIZf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 04:25:35 -0400
Received: from mxback11g.mail.yandex.net (mxback11g.mail.yandex.net [IPv6:2a02:6b8:0:1472:2741:0:8b7:90])
        by forward102o.mail.yandex.net (Yandex) with ESMTP id 189555A023F9
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:17:28 +0300 (MSK)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I updated the kernel 4.12.6. When the mote is hung on the route more than 8 mpls of marks through iproute2, I get the following:

root@ne-vlezay80:~# ip route add 10.10.10.0/24 encap mpls 50/60/70/80/90/100/110/120/130 dev lo
RTNETLINK answers: Invalid argument

root@ne-vlezay80:~# ip route add 10.10.10.0/24 encap mpls 50/60/70/80/90/100/110/120 dev lo
root@ne-vlezay80:~#

root@ne-vlezay80:~# ip r
default via 10.247.0.1 dev ic-br0 proto zebra metric 20 
10.10.10.0/24  encap mpls  ///////120 dev lo scope link 

root@ne-vlezay80:~# cat /usr/src/linux-4.12.6/net/mpls/internal.h|grep MAX_NEW
#define MAX_NEW_LABELS 30
root@ne-vlezay80:~# 

What is the problem, and how can more than 8 MPLS markers be hung on through iproute2?

root@ne-vlezay80:~# uname -r
4.12.6
root@ne-vlezay80:~# 
