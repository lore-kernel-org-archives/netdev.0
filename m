From: Didier Barvaux <didier@barvaux.org>
Subject: [IPv6] policy routing ?
Date: Wed, 6 Apr 2005 10:04:01 +0200
Message-ID: <20050406100401.0eab9374.didier@barvaux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello,


I'm trying to do policy routing with IPv6 (source routing) on a 2.6.11 kernel. It works perfectly well with IPv4 using iproute2 (iproute2-2.6.11-050330), but it doesn't seem to work with IPv6.


# ip -6 rule add from fec0:6::/64 priority 2000 table 100
RTNETLINK answers: Invalid argument
# echo $?
2
# ip -6 route add fec0:7::/64 via fec0:2::1 table 100
# echo $?
0
# ip -6 route show table 100
(no output)
# ip -6 route show table main
(snip)
fec0:7::/64 via fec0:2::1 dev eth1 metric 1024 mtu 1500 advmss 1440 metric10 64
(snip)

To add an IPv6 routing rule fails. To add an IPv6 route succeeds, but route is not added to the desired table ('main' instead of '100').


My kernel configuration contains:
CONFIG_IP_ADVANCED_ROUTER=y
CONFIG_IP_MULTIPLE_TABLES=y
CONFIG_IP_ROUTE_FWMARK=y

I searched on the web and in the netdev archives without great success (I found some messages of guys with the same problem, but no solution/answer).

Did I make a mistake ? Doesn't iproute2 manage IPv6 policy routing yet ? Or, is it a problem related to my 2.6 kernel configuration ? Could libnl be the solution ?


Regards,

Didier Barvaux
