From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 2/3] openvswitch: Treat IP_CT_RELATED as new
Date: Wed, 14 Oct 2015 11:10:48 -0700
Message-ID: <1444846249-52053-3-git-send-email-joestringer@nicira.com>
References: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:34767 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932093AbbJNSK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 14:10:59 -0400
Received: by payp3 with SMTP id p3so12941540pay.1
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 11:10:58 -0700 (PDT)
In-Reply-To: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New, related connections are marked as such as part of ovs_ct_lookup(),
but they are not marked as "new" if the commit flag is used. Make this
consistent by treating IP_CT_RELATED as new as well.

Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 net/openvswitch/conntrack.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 80bf702715bb..480dbb9095b7 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -86,6 +86,8 @@ static u8 ovs_ct_get_state(enum ip_conntrack_info ctinfo)
 		ct_state |= OVS_CS_F_ESTABLISHED;
 		break;
 	case IP_CT_RELATED:
+		ct_state |= OVS_CS_F_NEW;
+		/* Fall through */
 	case IP_CT_RELATED_REPLY:
 		ct_state |= OVS_CS_F_RELATED;
 		break;
-- 
2.1.4
