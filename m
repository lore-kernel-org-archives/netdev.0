From: md@Linux.IT (Marco d'Itri)
Subject: broken link-local multicast?
Date: Thu, 14 Feb 2008 17:28:34 +0100
Message-ID: <20080214162834.GA29186@bongo.bofh.it>
Reply-To: md@linux.it, netdev@vger.kernel.org
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from attila.bofh.it ([213.92.8.2]:54436 "EHLO attila.bofh.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755589AbYBNQ5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Feb 2008 11:57:18 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Link-local multicast appears to be broken on some interfaces of some of
my firewalls. I think that this started after I configured quagga's
ospf6d (which does not work because of this), but I am not totally sure.

Does anybody have any idea about how to debug this?

root@frwl-5a:~# ping6 -c 1 -I eth1 ff02::1
connect: Network is unreachable

root@frwl-5a:~# ping6 -c 1 -I eth0 ff02::1
PING ff02::1(ff02::1) from fe80::204:23ff:fed8:7dc eth0: 56 data bytes
64 bytes from fe80::204:23ff:fed8:7dc: icmp_seq=1 ttl=64 time=0.032 ms

--- ff02::1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.032/0.032/0.032/0.000 ms

root@frwl-5a:~# ip -6 ro | egrep '^fe80:.* eth[01] '
fe80::/64 dev eth0  metric 256  expires 18788161sec mtu 1500 advmss 1440 hoplimit 4294967295
fe80::/64 dev eth1  metric 256  expires 18788161sec mtu 1500 advmss 1440 hoplimit 4294967295

root@frwl-5a:~# uname -a
Linux frwl-5a 2.6.18-3-686 #1 SMP Mon Dec 4 16:41:14 UTC 2006 i686 GNU/Linux

-- 
ciao,
Marco
