From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 0/5] Ease netns management by userland
Date: Wed, 12 Dec 2012 18:24:36 +0100
Message-ID: <1355333081-4018-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, ebiederm@xmission.com, aatteka@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:39147 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735Ab2LLR0e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 12:26:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The goal of this serie is to ease netns management by daemons. Some systems use
netns only to virtualize network stack and don't want to multiply userland
daemons.  These system may have a lot of netns, up to 2000. We don't want to
launch an instance of each daemons (quagga, strongswan, conntrackd, ...) for
each netns because it will consume a lot of ressources. Having one daemon that
manage all netns is more efficient (mainly if there are few objects to manage:
one or two routes per netns for example).
Hence, one goal of this serie is to allow, for a daemon, to monitor netns
activities, thus it can open or close netlink sockets, allocating structures
needed to manage these netns when they are created or deleted.
To help to identify a netns, an index has been added to each netns.

A new setsockopt() option is also added, to help daemons to open socket in the
right netns. For now, a daemon that want to open a socket in a specified netns,
need to call setns(CLONE_NEWNET) with a fd (not so easy to found), open the
socket and then call again setns() to go back in the initial netns. Having this
kind of setsockopt() will simplify operations. Obviously, this setsockopt()
should be done enough early (is test on sk_state enough?). The first target is
netlink socket but it can be useful for other kind of socket, it's why a add a
generic socket option.

As usual, the patch against iproute2 will be sent once the patches are included
and net-next merged. I can send it on demand.

 arch/alpha/include/asm/socket.h        |   2 +
 arch/avr32/include/uapi/asm/socket.h   |   2 +
 arch/frv/include/uapi/asm/socket.h     |   2 +
 arch/h8300/include/asm/socket.h        |   2 +
 arch/ia64/include/uapi/asm/socket.h    |   2 +
 arch/m32r/include/asm/socket.h         |   2 +
 arch/m68k/include/uapi/asm/socket.h    |   2 +
 arch/mips/include/uapi/asm/socket.h    |   2 +
 arch/mn10300/include/uapi/asm/socket.h |   2 +
 arch/parisc/include/uapi/asm/socket.h  |   2 +
 arch/powerpc/include/uapi/asm/socket.h |   2 +
 arch/s390/include/uapi/asm/socket.h    |   2 +
 arch/sparc/include/uapi/asm/socket.h   |   2 +
 arch/xtensa/include/uapi/asm/socket.h  |   2 +
 include/net/net_namespace.h            |   3 +
 include/uapi/asm-generic/socket.h      |   2 +
 include/uapi/linux/if_link.h           |   1 +
 include/uapi/linux/netns.h             |  31 +++++
 net/core/net_namespace.c               | 223 +++++++++++++++++++++++++++++++++
 net/core/rtnetlink.c                   |   7 +-
 net/core/sock.c                        |  28 +++++
 net/netlink/genetlink.c                |   4 +
 22 files changed, 326 insertions(+), 1 deletion(-)

I do not pretend to be a netns expert, it's why I add RFC in the title ;-)

Comments are welcome.

Regards,
Nicolas
