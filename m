From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH 00/10] netpoll: Cleanup received packet processing
Date: Fri, 14 Mar 2014 20:43:13 -0700
Message-ID: <877g7wqg8e.fsf_-_@xmission.com>
References: <87eh28cvi6.fsf@xmission.com>
	<20140313.152311.1995854418463980325.davem@davemloft.net>
	<87eh24uu3d.fsf_-_@xmission.com>
	<20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:54107 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754667AbaCODnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 23:43:19 -0400
In-Reply-To: <87k3bwqgf7.fsf@xmission.com> (Eric W. Biederman's message of
	"Fri, 14 Mar 2014 20:39:08 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is the long-winded, careful, and polite version of removing the netpoll
receive packet processing.

First I untangle the code in small steps.  Then I modify the code to not
force reception and dropping of packets when we are transmiting a packet
with netpoll.  Finally I move all of the packet reception under
CONFIG_NETPOLL_TRAP and delete CONFIG_NETPOLL_TRAP.

If someone wants to do a stable backport of these patches, it would
require backporting the first 18 patches that handle the budget == 0 in
the networking drivers, and the first 6 of these patches.

If anyone wants to resurrect netpoll packet reception someday it should
just be a matter of reverting the last patch.

Eric W. Biederman (10):
      netpoll: move setting of NETPOLL_RX_DROP into netpoll_poll_dev
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
 net/core/netpoll.c        |  492 +--------------------------------------------
 5 files changed, 7 insertions(+), 579 deletions(-)

Eric
