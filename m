From: Pavlin Radoslavov <pavlin@icir.org>
Subject: Deleting tun interface and NETLINK messages ordering
Date: Fri, 19 Mar 2004 19:14:51 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200403200314.i2K3EpRj032698@possum.icir.org>
Cc: pavlin@icir.org
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

[ OS: RedHat-7.2 with 2.4.18 kernel ]

I was playing with adding/deleting tunnel interfaces (interface name
"tun") by using openvpn (http://openvpn.sourceforge.net/), and I
noticed that when I start openvpn the kernel sends the NETLINK
upcalls with the new information to user-space in the following
order:

  1. RTM_NEWLINK
  2. RTM_NEWADDR

I.e., first the "interface added" message, and then the
"address added" message.


However, when I quit openvpn, the NETLINK upcall messages appear in
the following order:

  1. RTM_DELLINK
  2. RTM_DELADDR

I.e., first the "interface deleted" message, and then the
"address deleted" message.

I would have expect that when an interface is deleted, the
RTM_DELADDR message(s) will appear first, and then the RTM_DELLINK
message.

Indeed, when the userland process that monitors the network
interface status receives the RTM_DELLINK message it can remove all
state about that interface (including its addresses), but then it
should be aware that it may receive RTM_DELADDR for non-existing
interface.

Thanks,
Pavlin
