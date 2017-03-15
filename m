From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 9/9] mlxsw: spectrum_router: Don't abort on l3mdev rules
Date: Wed, 15 Mar 2017 12:05:12 +0100
Message-ID: <1489575912-6469-10-git-send-email-jiri@resnulli.us>
References: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:36529 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753857AbdCOLF1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 07:05:27 -0400
Received: by mail-wr0-f196.google.com with SMTP id l37so1589263wrc.3
        for <netdev@vger.kernel.org>; Wed, 15 Mar 2017 04:05:26 -0700 (PDT)
In-Reply-To: <1489575912-6469-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Before we allow port netdevs to be enslaved to a VRF master we need to
make sure the device's routing tables won't be flushed upon the
insertion of a l3mdev rule.

Note that we assume the notified l3mdev rule is a simple rule as used by
the VRF master. We don't check for the presence of other selectors such
as 'iif' and 'oif'.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 4924d9f..04c8c56 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2563,7 +2563,7 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
 		rule = fib_work->fr_info.rule;
-		if (!mlxsw_sp_fib4_rule_default(rule))
+		if (!mlxsw_sp_fib4_rule_default(rule) && !rule->l3mdev)
 			mlxsw_sp_router_fib4_abort(mlxsw_sp);
 		fib_rule_put(rule);
 		break;
-- 
2.7.4
