From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net 1/6] rtnetlink: bring NETDEV_CHANGEMTU event process back in rtnetlink_event
Date: Sun, 15 Oct 2017 18:13:41 +0800
Message-ID: <d7713874f0ad1c19b640eaae98f0d554d1743a4c.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, David Ahern <dsahern@gmail.com>,
        hannes@stressinduktion.org
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:57028 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750924AbdJOKOD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 15 Oct 2017 06:14:03 -0400
Received: by mail-pg0-f67.google.com with SMTP id m18so4551807pgd.13
        for <netdev@vger.kernel.org>; Sun, 15 Oct 2017 03:14:02 -0700 (PDT)
In-Reply-To: <cover.1508062280.git.lucien.xin@gmail.com>
In-Reply-To: <cover.1508062280.git.lucien.xin@gmail.com>
References: <cover.1508062280.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 085e1a65f04f ("rtnetlink: Do not generate notifications for MTU
events") tried to fix the redundant notifications issue when ip link
set mtu by removing NETDEV_CHANGEMTU event process in rtnetlink_event.

But it also resulted in no notification generated when dev's mtu is
changed via other methods, like:
  'ifconfig eth1 mtu 1400' or 'echo 1400 > /sys/class/net/eth1/mtu'
It would cause users not to be notified by this change.

This patch is to fix it by bringing NETDEV_CHANGEMTU event back into
rtnetlink_event, and the redundant notifications issue will be fixed
in the later patch 'rtnetlink: check DO_SETLINK_NOTIFY correctly in
do_setlink'.

Fixes: 085e1a65f04f ("rtnetlink: Do not generate notifications for MTU events")
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/core/rtnetlink.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d4bcdcc..72053ed 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4279,6 +4279,7 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 
 	switch (event) {
 	case NETDEV_REBOOT:
+	case NETDEV_CHANGEMTU:
 	case NETDEV_CHANGEADDR:
 	case NETDEV_CHANGENAME:
 	case NETDEV_FEAT_CHANGE:
-- 
2.1.0
