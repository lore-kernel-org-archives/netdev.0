From: Wichert Akkerman <wichert@wiggy.net>
Subject: ipv6 tunnel stops accepting input
Date: Tue, 11 Jan 2005 13:58:26 +0100
Message-ID: <20050111125826.GA25169@wiggy.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I have an interesting problem with an ipv6 tunnel, which has been
present for some time now (at least 2.6.6 had the same problem, possibly
older kernels as well).

When I connect to my machine through a tunnel a icmp port unreachable
is returned:

13:39:39.320316 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: S 3800196387:3800196387(0) win 5760 <mss[|tcp]>
13:39:39.320539 IP home.wiggy.net > ipv6-tb.xs4all.net: icmp 108: home.wiggy.net protocol 41 port 0 unreachable

but once I do a ping6 from my machine to the outside world:

13:39:53.264393 IP home.wiggy.net > ipv6-tb.xs4all.net: tunnel29.ipv6.xs4all.nl > irc.ipv6.xs4all.nl: icmp6: echo request seq 1
13:39:53.299071 IP ipv6-tb.xs4all.net > home.wiggy.net: irc.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: icmp6: echo reply seq 1

the tunnel suddenly accepts incoming traffic:

13:40:00.324220 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: S 3800196387:3800196387(0) win 5760 <mss[|tcp]>
13:40:00.325950 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: S 4249094159:4249094159(0) ack 3800196388 win 5712 <mss[|tcp]>

If I do not generate any ipv6 for a while (I have not timed how long)
things revert to the original state again and no incoming traffic is
accepted until I generate some outgoing traffic.

More complete tcpdump is below.

Wichert.



tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on eth1, link-type EN10MB (Ethernet), capture size 96 bytes
13:39:39.320316 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: S 3800196387:3800196387(0) win 5760 <mss[|tcp]>
13:39:39.320539 IP home.wiggy.net > ipv6-tb.xs4all.net: icmp 108: home.wiggy.net protocol 41 port 0 unreachable
13:39:42.319721 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: S 3800196387:3800196387(0) win 5760 <mss[|tcp]>
13:39:42.319917 IP home.wiggy.net > ipv6-tb.xs4all.net: icmp 108: home.wiggy.net protocol 41 port 0 unreachable
13:39:44.374037 IP ipv6-tb.xs4all.net > home.wiggy.net: xs4all29.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: [|icmp6]
13:39:44.374194 IP home.wiggy.net > ipv6-tb.xs4all.net: icmp 92: home.wiggy.net protocol 41 port 0 unreachable
13:39:45.371013 IP ipv6-tb.xs4all.net > home.wiggy.net: xs4all29.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: [|icmp6]
13:39:45.371164 IP home.wiggy.net > ipv6-tb.xs4all.net: icmp 92: home.wiggy.net protocol 41 port 0 unreachable
13:39:46.371279 IP ipv6-tb.xs4all.net > home.wiggy.net: xs4all29.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: [|icmp6]
13:39:46.371396 IP home.wiggy.net > ipv6-tb.xs4all.net: icmp 92: home.wiggy.net protocol 41 port 0 unreachable
13:39:48.318920 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: S 3800196387:3800196387(0) win 5760 <mss[|tcp]>
13:39:48.319037 IP home.wiggy.net > ipv6-tb.xs4all.net: icmp 108: home.wiggy.net protocol 41 port 0 unreachable
13:39:53.264393 IP home.wiggy.net > ipv6-tb.xs4all.net: tunnel29.ipv6.xs4all.nl > irc.ipv6.xs4all.nl: icmp6: echo request seq 1
13:39:53.299071 IP ipv6-tb.xs4all.net > home.wiggy.net: irc.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: icmp6: echo reply seq 1
13:39:53.372094 IP ipv6-tb.xs4all.net > home.wiggy.net: xs4all29.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: [|icmp6]
13:39:53.372284 IP home.wiggy.net > ipv6-tb.xs4all.net: tunnel29.ipv6.xs4all.nl > xs4all29.ipv6.xs4all.nl: [|icmp6]
13:39:54.265389 IP home.wiggy.net > ipv6-tb.xs4all.net: tunnel29.ipv6.xs4all.nl > irc.ipv6.xs4all.nl: icmp6: echo request seq 2
13:39:54.278987 IP ipv6-tb.xs4all.net > home.wiggy.net: irc.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: icmp6: echo reply seq 2
13:39:55.267149 IP home.wiggy.net > ipv6-tb.xs4all.net: tunnel29.ipv6.xs4all.nl > irc.ipv6.xs4all.nl: icmp6: echo request seq 3
13:39:55.282790 IP ipv6-tb.xs4all.net > home.wiggy.net: irc.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: icmp6: echo reply seq 3
13:39:56.267934 IP home.wiggy.net > ipv6-tb.xs4all.net: tunnel29.ipv6.xs4all.nl > irc.ipv6.xs4all.nl: icmp6: echo request seq 4
13:39:56.282112 IP ipv6-tb.xs4all.net > home.wiggy.net: irc.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: icmp6: echo reply seq 4
13:39:57.268716 IP home.wiggy.net > ipv6-tb.xs4all.net: tunnel29.ipv6.xs4all.nl > irc.ipv6.xs4all.nl: icmp6: echo request seq 5
13:39:57.285870 IP ipv6-tb.xs4all.net > home.wiggy.net: irc.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: icmp6: echo reply seq 5
13:39:58.269504 IP home.wiggy.net > ipv6-tb.xs4all.net: tunnel29.ipv6.xs4all.nl > irc.ipv6.xs4all.nl: icmp6: echo request seq 6
13:39:58.286670 IP ipv6-tb.xs4all.net > home.wiggy.net: irc.ipv6.xs4all.nl > tunnel29.ipv6.xs4all.nl: icmp6: echo reply seq 6
13:40:00.324220 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: S 3800196387:3800196387(0) win 5760 <mss[|tcp]>
13:40:00.325950 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: S 4249094159:4249094159(0) ack 3800196388 win 5712 <mss[|tcp]>
13:40:00.346751 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: . ack 1 win 5760 <nop,nop,[|tcp]>
13:40:00.398508 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: P 1:40(39) ack 1 win 45 <nop,nop,[|tcp]>
13:40:00.438006 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: . ack 40 win 5760 <nop,nop,[|tcp]>
13:40:00.438560 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: P 1:42(41) ack 40 win 5760 <nop,nop,[|tcp]>
13:40:00.438904 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: . ack 42 win 45 <nop,nop,[|tcp]>
13:40:00.469593 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: P 42:650(608) ack 40 win 5760 <nop,nop,[|tcp]>
13:40:00.498866 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: P 40:584(544) ack 42 win 45 <nop,nop,[|tcp]>
13:40:00.539856 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: . ack 650 win 55 <nop,nop,[|tcp]>
13:40:00.571197 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: P 650:674(24) ack 584 win 6528 <nop,nop,[|tcp]>
13:40:00.571858 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: . ack 674 win 55 <nop,nop,[|tcp]>
13:40:00.595850 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: P 584:736(152) ack 674 win 55 <nop,nop,[|tcp]>
13:40:00.627863 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: P 674:818(144) ack 736 win 7616 <nop,nop,[|tcp]>
13:40:00.667764 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: . ack 818 win 55 <nop,nop,[|tcp]>
13:40:00.680831 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: P 736:1200(464) ack 818 win 55 <nop,nop,[|tcp]>
13:40:00.756581 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: . ack 1200 win 8704 <nop,nop,[|tcp]>
13:40:00.762006 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: P 818:834(16) ack 1200 win 8704 <nop,nop,[|tcp]>
13:40:00.762355 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: . ack 834 win 55 <nop,nop,[|tcp]>
13:40:00.785322 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: P 834:882(48) ack 1200 win 8704 <nop,nop,[|tcp]>
13:40:00.788806 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: . ack 882 win 55 <nop,nop,[|tcp]>
13:40:00.793799 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: P 1200:1248(48) ack 882 win 55 <nop,nop,[|tcp]>
13:40:00.821611 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: . ack 1248 win 8704 <nop,nop,[|tcp]>
13:40:00.828011 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: P 882:946(64) ack 1248 win 8704 <nop,nop,[|tcp]>
13:40:00.860787 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: P 1248:1328(80) ack 946 win 55 <nop,nop,[|tcp]>
13:40:00.885253 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: P 946:1042(96) ack 1328 win 8704 <nop,nop,[|tcp]>
13:40:00.885878 IP home.wiggy.net > ipv6-tb.xs4all.net: tornado.wiggy.net.ssh > 2001:960:6a6:1:240:caff:fe85:d77e.37399: P 1328:1408(80) ack 1042 win 55 <nop,nop,[|tcp]>
13:40:00.952432 IP ipv6-tb.xs4all.net > home.wiggy.net: 2001:960:6a6:1:240:caff:fe85:d77e.37399 > tornado.wiggy.net.ssh: . ack 1408 win 8704 <nop,nop,[|tcp]>]

-- 
Wichert Akkerman <wichert@wiggy.net>    It is simple to make things.
http://www.wiggy.net/                   It is hard to make things simple.
