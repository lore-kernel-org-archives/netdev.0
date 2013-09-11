From: Jeff Loughridge <jeffl@alumni.duke.edu>
Subject: ip l2tp - suspected defect using IPv6 local/remote addresses
Date: Wed, 11 Sep 2013 14:52:11 -0400
Message-ID: <CAG2uBVfwNOj_jKvaHV_66qrrBU5adDoqDWMvV7seNWfsG4RVAQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:64541 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754138Ab3IKSwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 14:52:32 -0400
Received: by mail-ie0-f175.google.com with SMTP id 9so5956173iec.34
        for <netdev@vger.kernel.org>; Wed, 11 Sep 2013 11:52:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using IPv6 address as L2TPv3 endpoints doesn't seem to work in
iproute2 3.11. I see a cosmetic defect in the output of 'ip l2tp show
tunnel'. In addition, I can't get tunnels to function with UDP or IP
encapsulation.

root@debian:~# ip l2tp add tunnel tunnel_id 3000 peer_tunnel_id 4000
encap udp local a::1 remote a::2 udp_sport 5000 udp_dport 6000
root@debian:~# ip l2tp add session tunnel_id 3000 session_id 1000
peer_session_id 2000
root@debian:~# ip l2tp show tunnel
Tunnel 3000, encap UDP
  From 127.0.0.1 to 127.0.0.1
  Peer tunnel 4000
  UDP source / dest ports: 5000/6000
root@debian:~#

See below for more details about my set-up. I have no problems using
IPv4 endpoints.

root@debian:~# ip addr show eth0
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
state UNKNOWN group default qlen 1000
    link/ether 00:0c:29:91:cb:3c brd ff:ff:ff:ff:ff:ff
    inet 5.1.0.100/24 scope global eth0
    inet6 a::1/64 scope global
       valid_lft forever preferred_lft forever
    inet6 fe80::20c:29ff:fe91:cb3c/64 scope link
       valid_lft forever preferred_lft forever
root@debian:~#
root@debian:~# ip -V
ip utility, iproute2-ss130903
root@debian:~# uname -a
Linux debian 3.2.0-4-686-pae #1 SMP Debian 3.2.41-2 i686 GNU/Linux
root@debian:~#
root@debian:~# modprobe l2tp_eth
root@debian:~# lsmod | grep l2tp
l2tp_eth               12738  0
l2tp_netlink           17263  1 l2tp_eth
l2tp_core              17486  2 l2tp_netlink,l2tp_eth

Jeff L.
