From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 0/3] macvlan: fix some problem if mac address changes
Date: Thu, 5 Jun 2014 20:01:00 +0800
Message-ID: <1401969663-4464-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>, <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:31282 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751349AbaFEMCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 08:02:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvlan may return failed when handle the NETDEV_CHANGEMTU message, and
the current code could not process the error value, so modify the
dev_set_mac_address to process the return value for notification chain,
revert the old mac address if set new mac address failed.

The macvlan and lowerdev should not have the same mac address for non-passthru
mode, so add restriction for that.

v1->v2: some drivers need to call ndo_set_mac_address() even though the same
        mac address, so remove the equal check and allow to set same mac address.

Ding Tianhong (3):
  macvlan: don't update the uc and vlan list for L2 forwarding offload
  net: dev: revert the mac address when notifier failed
  macvlan: don't set the same mac address for non-passthru mode

 drivers/net/macvlan.c |  8 ++++++--
 net/core/dev.c        | 23 +++++++++++++++++++----
 2 files changed, 25 insertions(+), 6 deletions(-)

-- 
1.8.0
