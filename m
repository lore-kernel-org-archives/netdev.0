From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH 0/6] netpoll: Cleanups and fixes
Date: Mon, 17 Mar 2014 23:22:38 -0700
Message-ID: <87iorcgh5d.fsf_-_@xmission.com>
References: <20140314.225923.61318448733570839.davem@davemloft.net>
	<87k3bwqgf7.fsf@xmission.com> <877g7wqg8e.fsf_-_@xmission.com>
	<20140317.154916.2276987764507311378.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: stephen@networkplumber.org, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:57911 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751851AbaCRGWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Mar 2014 02:22:46 -0400
In-Reply-To: <20140317.154916.2276987764507311378.davem@davemloft.net> (David
	Miller's message of "Mon, 17 Mar 2014 15:49:16 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This is a set of small cleanups and fixes for netpoll that makes the
code a little more penetratable and reliable.

The most significant is patch 6 which adds the function
skb_irq_freeable.  Patch 6 makes use of skb_irq_freeable to simplify the
logic in the network stack by freeing skbs as soon as possible and
making the buggy function zap_completion_queue in netpoll completely
pointless and thus unnecessary.

Eric W. Biederman (6):
      netpoll: Remove gfp parameter from __netpoll_setup
      netpoll: Only call ndo_start_xmit from a single place
      netpoll: Don't allow on devices that perform their own xmit locking
      netpoll: Move rx enable/disable into __dev_close_many
      netpoll: Rename netpoll_rx_enable/disable to netpoll_poll_disable/enable
      net: Free skbs from irqs when possible.

 drivers/net/bonding/bond_main.c |    6 +-
 drivers/net/team/team.c         |   16 +++---
 include/linux/netdevice.h       |    3 +-
 include/linux/netpoll.h         |   10 ++--
 include/linux/skbuff.h          |   13 +++++
 net/8021q/vlan_dev.c            |    7 +--
 net/bridge/br_device.c          |   15 +++---
 net/bridge/br_if.c              |    2 +-
 net/bridge/br_private.h         |    4 +-
 net/core/dev.c                  |   31 +++++------
 net/core/netpoll.c              |  110 ++++++++++++++++-----------------------
 net/core/skbuff.c               |   13 ++++-
 12 files changed, 112 insertions(+), 118 deletions(-)
