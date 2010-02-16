From: Ajit Khaparde <ajitkhaparde@gmail.com>
Subject: [PATCH net-2.6] be2net: set proper value to version field in req
 hdr
Date: Tue, 16 Feb 2010 15:48:46 +0530
Message-ID: <20100216101749.GA9465@serverengines.com>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f185.google.com ([209.85.223.185]:40472 "EHLO
	mail-iw0-f185.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932603Ab0BPKSw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 05:18:52 -0500
Received: by iwn15 with SMTP id 15so5646269iwn.19
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2010 02:18:50 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before sending a command to the ASIC, set version properly.
This is necessary for the ARM firmware to send correct data to the driver.
This also fixes a bug in certain skews of the ASIC where the statistics
are misreported.

Signed-off-by: Ajit Khaparde <ajitk@serverengines.com>
---
 drivers/net/benet/be_cmds.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_cmds.c b/drivers/net/benet/be_cmds.c
index fee6eee..006cb2e 100644
--- a/drivers/net/benet/be_cmds.c
+++ b/drivers/net/benet/be_cmds.c
@@ -296,6 +296,7 @@ static void be_cmd_hdr_prepare(struct be_cmd_req_hdr *req_hdr,
 	req_hdr->opcode = opcode;
 	req_hdr->subsystem = subsystem;
 	req_hdr->request_length = cpu_to_le32(cmd_len - sizeof(*req_hdr));
+	req_hdr->version = 0;
 }
 
 static void be_cmd_page_addrs_prepare(struct phys_addr *pages, u32 max_pages,
-- 
1.6.3.3

