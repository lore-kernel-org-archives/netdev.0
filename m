From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/2] team: block mtu change before it happens via NETDEV_PRECHANGEMTU
Date: Thu, 16 Jan 2014 00:02:19 +0100
Message-ID: <1389826939-20691-2-git-send-email-vfalico@redhat.com>
References: <1389826939-20691-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jiri Pirko <jiri@resnulli.us>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62821 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854AbaAOXGs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 18:06:48 -0500
In-Reply-To: <1389826939-20691-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now it catches the NETDEV_CHANGEMTU notification, which is signaled after
the actual change happened on the device, and returns NOTIFY_BAD, so that
the change on the device is reverted.

This might be quite costly and messy, so use the new NETDEV_PRECHANGEMTU to
catch the MTU change before the actual change happens and signal that it's
forbidden to do it.

CC: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/team/team.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
index b75ae5b..dff24e3 100644
--- a/drivers/net/team/team.c
+++ b/drivers/net/team/team.c
@@ -2851,7 +2851,7 @@ static int team_device_event(struct notifier_block *unused,
 	case NETDEV_FEAT_CHANGE:
 		team_compute_features(port->team);
 		break;
-	case NETDEV_CHANGEMTU:
+	case NETDEV_PRECHANGEMTU:
 		/* Forbid to change mtu of underlaying device */
 		return NOTIFY_BAD;
 	case NETDEV_PRE_TYPE_CHANGE:
-- 
1.8.4
