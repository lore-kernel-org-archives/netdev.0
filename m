From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 1/4] Added ASSERT_RTNL() to dev_open() and dev_close().
Date: Tue, 6 May 2008 19:34:06 +0100
Message-ID: <20080506183405.GG2217@solarflare.com>
References: <20080506182654.GF2217@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:54039 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755040AbYEFSjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 May 2008 14:39:42 -0400
Content-Disposition: inline
In-Reply-To: <20080506182654.GF2217@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dev_open() and dev_close() must be called holding the RTNL, since they
call device functions and netdevice notifiers that are promised the RTNL.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 net/core/dev.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d334446..e76f4fd 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -994,6 +994,8 @@ int dev_open(struct net_device *dev)
 {
 	int ret = 0;
 
+	ASSERT_RTNL();
+
 	/*
 	 *	Is it already up?
 	 */
@@ -1060,6 +1062,8 @@ int dev_open(struct net_device *dev)
  */
 int dev_close(struct net_device *dev)
 {
+	ASSERT_RTNL();
+
 	might_sleep();
 
 	if (!(dev->flags & IFF_UP))

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.

