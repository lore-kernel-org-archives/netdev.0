From: Leon Goldberg <lgoldber@redhat.com>
Subject: ip route get oddly fails for ipv6
Date: Thu, 23 Feb 2017 16:43:37 +0200
Message-ID: <CA+mNUtDwDN9vwBZkwu2jyXoa+ziVYxw1Lij=EE5kDsNgKhDJAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Edward Haas <ehaas@redhat.com>, Dan Kenigsberg <danken@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:35066 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751098AbdBWOoY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 09:44:24 -0500
Received: by mail-lf0-f53.google.com with SMTP id z127so17252680lfa.2
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 06:43:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hey,

For some reason ip route get fails to retrieve ipv6 routes, although
the subject destination is indeed reachable:

[root@localhost tests]# ip -6 route
2001:1::/64 dev eth1  proto kernel  metric 256
fe80::/64 dev eth0  proto kernel  metric 256
fe80::/64 dev eth1  proto kernel  metric 256

[root@localhost tests]# ping6 2001:1::1
PING 2001:1::1(2001:1::1) 56 data bytes
64 bytes from 2001:1::1: icmp_seq=1 ttl=64 time=0.035 ms
64 bytes from 2001:1::1: icmp_seq=2 ttl=64 time=0.055 ms
64 bytes from 2001:1::1: icmp_seq=3 ttl=64 time=0.055 ms
^C
--- 2001:1::1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2000ms
rtt min/avg/max/mdev = 0.035/0.048/0.055/0.011 ms

[root@localhost tests]# ip route get 2001:1::1
[root@localhost tests]#
[root@localhost tests]# ip -6 route get 2001:1::1
[root@localhost tests]#

ipv4 ip route get works fine. Any hints?

Thanks,
Leon
