From: sfeldma@gmail.com
Subject: [PATCH net-next 1/5] rocker: zero allocate ports array
Date: Mon,  1 Jun 2015 11:39:02 -0700
Message-ID: <1433183947-13095-2-git-send-email-sfeldma@gmail.com>
References: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34450 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753744AbbFASh0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 14:37:26 -0400
Received: by payr10 with SMTP id r10so32385680pay.1
        for <netdev@vger.kernel.org>; Mon, 01 Jun 2015 11:37:26 -0700 (PDT)
In-Reply-To: <1433183947-13095-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

When allocating the array of rocker port pointers, zero the array values so
we can test for !NULL to see if port is allocated/registered.  We'll need
this later when installing untagged VLAN support for each port, during port
probe.  It's a long story, but to install a VLAN (vid=0 for untagged, in
this case) on a port, we'll need to scan other ports to see if the VLAN
group for that VLAN has been setup.  To scan the other ports, we need to
walk the port array.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 36f7edf..ab6d871 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4936,7 +4936,7 @@ static int rocker_probe_ports(struct rocker *rocker)
 	int err;
 
 	alloc_size = sizeof(struct rocker_port *) * rocker->port_count;
-	rocker->ports = kmalloc(alloc_size, GFP_KERNEL);
+	rocker->ports = kzalloc(alloc_size, GFP_KERNEL);
 	if (!rocker->ports)
 		return -ENOMEM;
 	for (i = 0; i < rocker->port_count; i++) {
-- 
1.7.10.4
