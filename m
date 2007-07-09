From: "Micah Gruber" <micah.gruber@gmail.com>
Subject: [PATCH] [2.6.22] Fix a potential NULL pointer dereference in free_shared_mem() in drivers/net/s2io.c
Date: Mon, 9 Jul 2007 11:29:04 +0800
Message-ID: <aaab98560707082029u52ffce5eia32cfb57a29db78f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.180]:29848 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758644AbXGID3F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jul 2007 23:29:05 -0400
Received: by py-out-1112.google.com with SMTP id d32so1443740pye
        for <netdev@vger.kernel.org>; Sun, 08 Jul 2007 20:29:04 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch fixes a potential null dereference bug where we dereference
nic before a null check. This patch simply moves the dereferencing
after the null check.

Signed-off-by: Micah Gruber < micah.gruber@gmail.com>

--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -789,12 +789,14 @@
        struct mac_info *mac_control;
        struct config_param *config;
        int lst_size, lst_per_page;
-       struct net_device *dev = nic->dev;
+       struct net_device *dev;
        int page_num = 0;

        if (!nic)
                return;

+       dev = nic->dev;
+
        mac_control = &nic->mac_control;
        config = &nic->config;
