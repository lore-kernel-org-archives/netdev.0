From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/9] netpoll: Cleanup received packet processing
Date: Fri, 14 Mar 2014 18:30:14 -0700
Message-ID: <87eh24uu3d.fsf_-_@xmission.com>
References: <1394540961.21721.22.camel@edumazet-glaptop2.roam.corp.google.com>
	<20140311082312.5ad00119@nehalam.linuxnetplumber.net>
	<87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:38951 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752107AbaCOBaV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 21:30:21 -0400
In-Reply-To: <20140313.152311.1995854418463980325.davem@davemloft.net> (David
	Miller's message of "Thu, 13 Mar 2014 15:23:11 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the long-winded, careful, and polite version of removing the netpoll
receive packet processing.

First I untangle the code in small steps.  Then I modify the code to not
force reception and dropping of packets when we are transmiting a packet
with netpoll.  Finally I move all of the packet reception under
CONFIG_NETPOLL_TRAP and delete CONFIG_NETPOLL_TRAP.

If someone wants to do a stable backport it would take backporting
the first 18 patches that handle the budget == 0 in the networking
drivers, and the first 5 of these patches.

If anyone wants to resurrect netpoll packet reception someday it should
just be a matter of reverting the last patch.

Eric W. Biederman (9):
      netpoll: Pass budget into poll_napi
      netpoll: Visit all napi handlers in poll_napi
      netpoll: Warn if more packets are processed than are budgeted
      netpoll: Add netpoll_rx_processing
      netpoll: Don't drop all received packets.
      netpoll: Move netpoll_trap under CONFIG_NETPOLL_TRAP
      netpoll: Consolidate neigh_tx processing in service_neigh_queue
      netpoll: Move all receive processing under CONFIG_NETPOLL_TRAP
      netpoll: Remove dead packet receive code (CONFIG_NETPOLL_TRAP)

 drivers/net/Kconfig       |    5 -
 include/linux/netdevice.h |   17 --
 include/linux/netpoll.h   |   61 ------
 net/core/dev.c            |   11 +-
 net/core/netpoll.c        |  488 +--------------------------------------------
 5 files changed, 5 insertions(+), 577 deletions(-)

Eric
