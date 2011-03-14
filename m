From: Doug Kehn <rdkehn@yahoo.com>
Subject: Multicast Fails Over Multipoint GRE Tunnel
Date: Mon, 14 Mar 2011 16:34:01 -0700 (PDT)
Message-ID: <998769.91206.qm@web39301.mail.mud.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web39301.mail.mud.yahoo.com ([66.94.238.168]:20969 "HELO
	web39301.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751554Ab1CNXkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 19:40:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

I'm running kernel version 2.6.36 on ARM XSCALE (big-endian) and multicast over a multipoint GRE tunnel isn't working.  For my architecture, this worked on 2.6.26.8.  For x86, multicast over a multipoint GRE tunnel worked with kernel version 2.6.31 but failed with version 2.6.35.  Multicast over a multipoint GRE tunnel fails because ipgre_header() fails the 'if (iph->daddr)' check and reutrns -t->hlen.  ipgre_header() is being called, from neigh_connected_output(), with a non-null daddr; the contents of daddr is zero.

Reverting the ip_gre.c patch posted in http://marc.info/?l=linux-netdev&m=126762491525281&w=2 resolves the problem.  (Reviewing the HEAD of net-next-2.6 it appears that ipgre_header() remains unchanged from 2.6.36.)

The configuration used to discover/diagnose the problem:

ip tunnel add tun1 mode gre key 11223344 ttl 64 csum remote any
ip link set dev tun1 up
ip link set dev tun1 multicast on
ip addr flush dev tun1
ip addr add 10.40.92.114/24 broadcast 10.40.92.255 dev tun1

12: tun1: <MULTICAST,NOARP,UP,10000> mtu 1468 qdisc noqueue
    link/gre 0.0.0.0 brd 0.0.0.0
    inet 10.40.92.114/24 brd 10.40.92.255 scope global tun1

Then attempt:
ping -I tun1 224.0.0.9

Are additional configuration steps now required for multicast over multipoint GRE tunnel or is ipgre_header() in error?

Thanks,
...doug



      
