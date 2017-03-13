From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 10/10] mlxsw: spectrum_router: Don't abort on l3mdev rules
Date: Mon, 13 Mar 2017 08:38:33 +0100
Message-ID: <1489390713-2634-10-git-send-email-jiri@resnulli.us>
References: <1489390535-2566-1-git-send-email-jiri@resnulli.us>
 <1489390713-2634-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        dsa@cumulusnetworks.com, shm@cumulusnetworks.com,
        kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, lorenzo@google.com, mateusz.bajorski@nokia.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35717 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751748AbdCMHiw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 03:38:52 -0400
Received: by mail-wm0-f65.google.com with SMTP id z63so8330253wmg.2
        for <netdev@vger.kernel.org>; Mon, 13 Mar 2017 00:38:50 -0700 (PDT)
In-Reply-To: <1489390713-2634-1-git-send-email-jiri@resnulli.us>
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
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index de54382..fa73ee2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2552,7 +2552,8 @@ static void mlxsw_sp_router_fib_event_work(struct work_struct *work)
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
-		if (!fib_work->fr_info.rule->def)
+		if (!fib_work->fr_info.rule->def &&
+		    !fib_work->fr_info.rule->l3mdev)
 			mlxsw_sp_router_fib4_abort(mlxsw_sp);
 		fib_rule_put(fib_work->fr_info.rule);
 		break;
-- 
2.7.4
