From: Yves =?ISO-8859-1?Q?Legrandg=E9rard?= <ylg@pps.jussieu.fr>
Subject: sendmsg/IPv6 routing header/bug
Date: Sat, 16 Oct 2004 10:32:08 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1097915528.12492.130.camel@pcylg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
	I've discovered the following bug in IPv6 stack:

1. `sendmsg' crash when sending a UDP datagram with a routing header
of type 0 (IPV6_RTHDR_TYPE_0) as ancillary data.

2. When sending a UDP datagram with such a routing header as ancillary
data,
`sendmsg' is interrupted on receiving SIG_SEGV (segment violation).

This bug concerns ONLY UDP protocol. More precisely, if you send, for
example, an ICMPv6 Echo Request with  a routing header of type 0 as
ancillary data, everything works properly.

There is a problem with routing header only. All other ancillary data,
hoplimit, pktinfo, nexthop, etc. are working fine.

3. This bug affects Linux versions from 2.4.21 to 2.4.27 included and
DOES NOT affect Linux 2.4.20. I have not tried with Linux 2.6.xx.

Thank you for your attention,
		[ylg].
