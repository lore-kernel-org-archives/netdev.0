From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net 2/3] openvswitch: Treat IP_CT_RELATED as new
Date: Fri, 16 Oct 2015 11:08:20 -0700
Message-ID: <1445018901-18839-3-git-send-email-joestringer@nicira.com>
References: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35726 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbJPSIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 14:08:34 -0400
Received: by padcn9 with SMTP id cn9so12035833pad.2
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 11:08:34 -0700 (PDT)
In-Reply-To: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New, related connections are marked as such as part of ovs_ct_lookup(),
but they are not marked as "new" if the commit flag is used. Make this
consistent by treating IP_CT_RELATED as new as well.

Reported-by: Jarno Rajahalme <jrajahalme@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
Acked-by: Pravin B Shelar <pshelar@nicira.com>
---
v2: Acked.
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
