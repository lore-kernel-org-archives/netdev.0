From: Tobias Waldekranz <tobias@waldekranz.com>
Subject: [PATCH] dsa: do not dereference non-existing routing table
Date: Thu, 5 Feb 2015 14:52:06 +0100
Message-ID: <20150205135206.GA29383@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:39789 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752019AbbBENwS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 08:52:18 -0500
Received: by mail-lb0-f177.google.com with SMTP id p9so7314463lbv.8
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 05:52:16 -0800 (PST)
Received: from gmail.com ([213.132.98.41])
        by mx.google.com with ESMTPSA id f9sm975440laa.20.2015.02.05.05.52.16
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=RC4-SHA bits=128/128);
        Thu, 05 Feb 2015 05:52:16 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the case where there is only one switch, no routing table will have
been allocated, so do not dereference it in this case.

Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>
---
 drivers/net/dsa/mv88e6131.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/dsa/mv88e6131.c b/drivers/net/dsa/mv88e6131.c
index 1fc98e7..eadb27c 100644
--- a/drivers/net/dsa/mv88e6131.c
+++ b/drivers/net/dsa/mv88e6131.c
@@ -142,7 +142,8 @@ static int mv88e6131_setup_global(struct dsa_switch *ds)
 		int nexthop;
 
 		nexthop = 0x1f;
-		if (i != ds->index && i < ds->dst->pd->nr_chips)
+		if (ds->pd->rtable &&
+		    i != ds->index && i < ds->dst->pd->nr_chips)
 			nexthop = ds->pd->rtable[i] & 0x1f;
 
 		REG_WRITE(REG_GLOBAL2, 0x06, 0x8000 | (i << 8) | nexthop);
-- 
1.8.4.357.g8d83871.dirty
