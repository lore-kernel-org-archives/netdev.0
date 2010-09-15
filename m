From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v2] drivers/net/eql.c: prevent reading uninitialized stack
 memory
Date: Wed, 15 Sep 2010 17:43:04 -0400
Message-ID: <1284586984.6275.92.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, security@kernel.org, stable@kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.vsecurity.com ([209.67.252.12]:63304 "EHLO
	mx1.vsecurity.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab0IOVt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 17:49:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fixed formatting (tabs and line breaks).

The EQL_GETMASTRCFG device ioctl allows unprivileged users to read 16
bytes of uninitialized stack memory, because the "master_name" member of
the master_config_t struct declared on the stack in eql_g_master_cfg()
is not altered or zeroed before being copied back to the user.  This
patch takes care of it.

Signed-off-by: Dan Rosenberg <dan.j.rosenberg@gmail.com>

--- linux-2.6.35.4.orig/drivers/net/eql.c	2010-08-26 19:47:12.000000000 -0400
+++ linux-2.6.35.4/drivers/net/eql.c	2010-09-14 21:25:27.719474445 -0400
@@ -555,6 +555,8 @@ static int eql_g_master_cfg(struct net_d
 	equalizer_t *eql;
 	master_config_t mc;
 
+	memset(&mc, 0, sizeof(master_config_t));
+
 	if (eql_is_master(dev)) {
 		eql = netdev_priv(dev);
 		mc.max_slaves = eql->max_slaves;





