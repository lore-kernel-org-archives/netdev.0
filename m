From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 0/4] macvlan: fix some problem if mac address changes
Date: Thu, 5 Jun 2014 14:50:24 +0800
Message-ID: <1401951028-9800-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:60345 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751255AbaFEGvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 02:51:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvlan may return failed when handle the NETDEV_CHANGEMTU message, and
the current code could not process the error value, so modify the
dev_set_mac_address to process the return value for notification chain,
revert the old mac address if set new mac address failed.

Set same mac address to the same netdev is unnecessary, so fix it.

The macvlan and lowerdev should not have the same mac address for non-passthru
mode, so add restriction for that.

Ding Tianhong (4):
  macvlan: don't update the uc and vlan list for L2 forwarding offload
  net: dev: don't set the same mac address for netdev
  net: dev: revert the mac address when notifier failed
  macvlan: don't set the same mac address for non-passthru mode

 drivers/net/macvlan.c |  8 ++++++--
 net/core/dev.c        | 25 +++++++++++++++++++++----
 2 files changed, 27 insertions(+), 6 deletions(-)

-- 
1.8.0
