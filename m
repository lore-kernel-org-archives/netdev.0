From: zyjzyj2000@gmail.com
Subject: [PATCH net-next 1/1] ixgbe: add fiber tranceiver plug/unplug notifier
Date: Tue, 14 Jun 2016 21:43:23 +0800
Message-ID: <1465911805-27528-1-git-send-email-zyjzyj2000@gmail.com>
To: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.129.214.122] ([222.129.214.122]:55722 "EHLO mail.zhuyj.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752251AbcFNNwz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jun 2016 09:52:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi, all

When the fiber tranceiver is plugged/unplugged from the nic, there is no any notifiers to indicate this events now.
This events sometimes are needed by the userspace tools or kernel.

So, 

Is there any interrupt to indicate the unplug event?
If no interrupt, is there any method to notify the unplug event?

I made a new patch to send the notifier when the fiber tranceiver is plugged/unplugged.

This patch is based on the function ixgbe_sfp_detection_subtask.

When the fiber tranceiver is plugged/unplugged, the value in the register is changed, then
NETDEV_FIBER_TRANCEIVER_UNPLUG notifier is sent.

This patch can work well with the following steps:

1. boot the host
2. ip link set eth0 up
3. unplug the fiber tranceiver
4. a message NETDEV_FIBER_TRANCEIVER_UNPLUG is sent
5. plug the fiber tranceiver
6. a notifier NETDEV_FIBER_TRANCEIVER_PLUG is sent

Please comment on it.

Thanks a lot.
Zhu Yanjun
