From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] vxlan: don't expire permanent entries
Date: Fri, 26 Oct 2012 09:24:34 -0700
Message-ID: <20121026092434.4d735316@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	John Southworth <john.southworth@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:56297 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965226Ab2JZQZV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 Oct 2012 12:25:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VXLAN confused flag versus bitmap on state.
Based on part of a earlier patch by David Stevens.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
---
Applies to 3.7.0-rc2. Needs to be fixed in 3.7 series

--- a/drivers/net/vxlan.c	2012-10-11 11:06:10.032585615 -0700
+++ b/drivers/net/vxlan.c	2012-10-26 09:19:30.734585097 -0700
@@ -816,7 +816,7 @@ static void vxlan_cleanup(unsigned long
 				= container_of(p, struct vxlan_fdb, hlist);
 			unsigned long timeout;
 
-			if (f->state == NUD_PERMANENT)
+			if (f->state & NUD_PERMANENT)
 				continue;
 
 			timeout = f->used + vxlan->age_interval * HZ;
