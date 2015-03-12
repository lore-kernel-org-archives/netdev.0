From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Subject: [PATCH V2 0/1] neighbour: Support broadcast ARP in neighbor PROPE state
Date: Thu, 12 Mar 2015 14:58:20 +0800
Message-ID: <1426143501-30827-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <brian.haley@hp.com>, <davem@davemloft.net>,
	<alexandre.dietsch@windriver.com>,
	<clinton.slabbert@windriver.com>, <kuznet@ms2.inr.ac.ru>,
	<jmorris@namei.org>, <kaber@trash.net>, <netdev@vger.kernel.org>,
	<ulf.samuelsson@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61604 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751121AbbCLG6n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 02:58:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2:
  set ARP_PROBE_BCAST default N.

V1:
  Have a problem with an HP router at a certain location, which
  is configured to only answer to broadcast ARP requests.
  That cannot be changed.

  The first ARP request the kernel sends out, is a broadcast request,
  which is fine, but after the reply, the kernel sends unicast requests,
  which will not get any replies.

  The ARP entry will after some time enter STALE state,
  and if nothing is done it will time out, and be removed.
  This process takes to long, and I have been told that it is
  difficult to makes changes that will eventually remove it.

  Have tried to change the state from STALE to INCOMPLETE, which failed,
  and then tried to change the state to PROBE which also failed.

  The stack is only sending out unicasts, and never broadcast.
  Is there any way to get the stack to send out a broadcast ARP
  without having to wait for the entry to be removed?

  I think the recommended behaviour in IPv6 is to send out 3 unicasts
  and if all fails, to send out broadcasts.

Zhu Yanjun (1):
  neighbour: Support broadcast ARP in neighbor PROPE state

 include/net/neighbour.h        |  7 ++++++
 include/uapi/linux/neighbour.h |  6 +++++
 include/uapi/linux/sysctl.h    |  3 +++
 kernel/sysctl_binary.c         |  3 +++
 net/core/neighbour.c           | 44 +++++++++++++++++++++++++++++---
 net/ipv4/Kconfig               | 57 ++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/arp.c                 |  7 ++++--
 7 files changed, 121 insertions(+), 6 deletions(-)

-- 
1.9.1
