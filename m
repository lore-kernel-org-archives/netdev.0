From: "Marco d'Itri" <md@Linux.IT>
Subject: IPv6 ND on PPC hardware
Date: Sat, 29 Jun 2002 16:39:01 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <20020629143901.GA1963@wonderland.linux.it>
Reply-To: netdev@oss.sgi.com, md@Linux.IT
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ipv6@lists.linux.it
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
List-Id: netdev.vger.kernel.org

I do not understand why ND is not working. Is my configuration wrong or
I have exposed a kernel bug?
When I try to ping another host on the LAN it usually works the first
time, and then stops working because the other host does not replies to
ND requests. Apparently verything works again if I switch the interface
in promiscuous mode.

erode:/# ip -6 ad
1: lo: <LOOPBACK,UP> mtu 16436 qdisc noqueue 
    inet6 ::1/128 scope host 
2: eth0: <BROADCAST,MULTICAST,UP> mtu 1500 qdisc pfifo_fast qlen 100
    inet6 3ffe:1001:210:16::3/64 scope global 
    inet6 3ffe:8271:a040:16::3/64 scope global 
    inet6 3ffe:8171:10:16::3/64 scope global 
    inet6 fe80::204:acff:fe97:7130/10 scope link 
erode:/# ip -6 ro
3ffe:1001:210:16::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
3ffe:8171:10:16::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
3ffe:8271:a040:16::/64 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
2000::/3 via 3ffe:1001:210:16::1 dev eth0  metric 1024  mtu 1500 advmss 1440
fe80::/10 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
ff00::/8 dev eth0  proto kernel  metric 256  mtu 1500 advmss 1440
unreachable default dev lo  metric -1  error -101
erode:/# uname -a
Linux erode 2.4.19-rc1 #1 Sat Jun 29 15:05:41 CEST 2002 ppc unknown

The other host has a similar configuration.

Seen from a third host (i386, which appears to work) on the same LAN:

16:23:22.818468 erode.bofh.it > ff02::1:ff00:1: icmp6: neighbor sol: who has attila.bofh.it(src lladdr: 0:4:ac:97:71:30) (len 32, hlim 255)
16:23:23.814589 erode.bofh.it > ff02::1:ff00:1: icmp6: neighbor sol: who has attila.bofh.it(src lladdr: 0:4:ac:97:71:30) (len 32, hlim 255)
16:23:24.814834 erode.bofh.it > ff02::1:ff00:1: icmp6: neighbor sol: who has attila.bofh.it(src lladdr: 0:4:ac:97:71:30) (len 32, hlim 255)
16:23:25.844675 erode.bofh.it > ff02::1:ff00:1: icmp6: neighbor sol: who has attila.bofh.it(src lladdr: 0:4:ac:97:71:30) (len 32, hlim 255)

-- 
ciao,
Marco
