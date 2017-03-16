From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 9/9] mlxsw: spectrum_router: Don't abort on l3mdev rules
Date: Thu, 16 Mar 2017 09:08:20 +0100
Message-ID: <1489651700-3586-10-git-send-email-jiri@resnulli.us>
References: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f193.google.com ([209.85.128.193]:33001 "EHLO
        mail-wr0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751448AbdCPIIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 04:08:46 -0400
Received: by mail-wr0-f193.google.com with SMTP id g10so4821616wrg.0
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 01:08:33 -0700 (PDT)
In-Reply-To: <1489651700-3586-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Now that port netdevs can be enslaved to a VRF master we need to make
sure the device's routing tables won't be flushed upon the insertion of
a l3mdev rule.

Note that we assume the notified l3mdev rule is a simple rule as used by
the VRF master. We don't check for the presence of other selectors such
as 'iif' and 'oif'.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index c89f4b4..488bc1f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2554,7 +2554,7 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
 		rule = fib_work->fr_info.rule;
-		if (!fib4_rule_default(rule))
+		if (!fib4_rule_default(rule) && !rule->l3mdev)
 			mlxsw_sp_router_fib4_abort(mlxsw_sp);
 		fib_rule_put(rule);
 		break;
-- 
2.7.4
