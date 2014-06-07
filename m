From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 RESEND 0/4] macvlan: fix some problem if mac address changes
Date: Sat, 7 Jun 2014 15:45:39 +0800
Message-ID: <1402127143-6456-1-git-send-email-dingtianhong@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <kaber@trash.net>, <davem@davemloft.net>, <edumazet@google.com>,
	<vyasevic@redhat.com>, <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:38486 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752789AbaFGHqs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jun 2014 03:46:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The macvlan may return failed when handle the NETDEV_CHANGEMTU message, and
the current code could not process the error value, so modify the
dev_set_mac_address to process the return value for notification chain,
revert the old mac address if set new mac address failed.

The macvlan and lowerdev should not have the same mac address for non-passthru
mode, so add restriction for that.

v1->v2: Now the current code support setting a same mac address for netdev, but
	most of time, it make no sense, but drivers need the user set flag regardless
	the address is same or not, so don't do anything only If the address has
	already been set by user and it is the same as before.

	If the lowerdev support L2 fwd offload, the macvlan address will be set to
	the hw rar only, and it the address changes, the fwd for macvlan need be rebuild,
	this patchset support this.

Ding Tianhong (4):
  macvlan: support mac address changes when fwd_priv is enable
  net: dev: revert the mac address when notifier failed
  macvlan: don't set the same mac address for non-passthru mode
  net: dev: don't set the same mac address for netdev

 drivers/net/macvlan.c | 27 ++++++++++++++++++++++++++-
 net/core/dev.c        | 30 ++++++++++++++++++++++++++----
 2 files changed, 52 insertions(+), 5 deletions(-)

-- 
1.8.0
