From: Szymon Miotk <spam@crocom.com.pl>
Subject: PROBLEM: Bad ARP requests make an entry in routing cache
Date: Wed, 30 Mar 2005 16:45:48 +0200
Message-ID: <424ABB9C.7070500@crocom.com.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[1.] One line summary of the problem:
Bad ARP requests make an entry in routing cache

[2.] Full description of the problem/report:
When there is client/router netmask mismatch (client has wider mask than 
the route), ARP request to non-existing local networks make an entry in 
routing cache on the router.
Example configuration in [6.]

[3.] Keywords (i.e., modules, networking, kernel):
networking, arp, routing

[4.] Kernel version (from /proc/version):
2.6.12-rc1
work also on 2.6.10_rc1_bk17, 2.6.11.
I have not tried earlier versions, because I need some bug-fixes 
introduced in 2.6.10_rc1_bk17

[5.] Output of Oops.. message (if applicable) with symbolic information
      resolved (see Documentation/oops-tracing.txt)
no oops here.

[6.] A small shell script or example program which triggers the
      problem (if possible)
Config:

[CLIENT eth0]-----[eth0 ROUTER eth1]-----internet

CLIENT eth0: 10.1.1.4/16
SERVER eth0: 10.1.1.1/24 (note the different netmasks!)
SERVER eth1: whatever
/proc/sys/net/ipv4/ip_forward=1

The session as follows:
server # route -Cn | grep 44

CLIENT # ping 10.1.44.44

server #  route -Cn |grep 44
10.1.1.4        10.1.44.44      153.19.190.40   i     0      0        2 eth1

The only packet, that arrives to the server is (according to tcpdump)
16:31:46.425917 arp who-has 10.1.44.44 tell 10.1.1.4

[7.] Environment
[7.1.] Software (add the output of the ver_linux script here)
Fedora Core 3

iproute-2.6.11-1 (the freshest I could get from 'developement' branch), 
works with older versions too

It's enough, when you leave
Packet Socket
Unix domain sockets
TCP/IP networking (all sub-options off)
in the 'networking options'.
It must be somewhere in the core networking/routing.

[X.] Other notes, patches, fixes, workarounds:
I have recompiled the kernel serveral times with different options.
No workaround.

The bug is a big problem, when you have netmask mismatch (well, I have 
few hundred clients with it and this cannot be fixed easily). A PC 
infected with a aggresive virus causes hundreds ARP requests per 
seconds, what in turns leads to routing cache overflows. This doesn't 
kill the router, but slows it down and there is significant delay, when 
making a new connection. I would call it 'soft DoS'.

Szymon Miotk
