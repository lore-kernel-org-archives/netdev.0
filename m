From: Phil Sutter <phil@nwl.cc>
Subject: [PATCH 2/6] misc/ss: avoid NULL pointer dereference
Date: Thu,  6 Aug 2015 14:24:32 +0200
Message-ID: <1438863876-1935-2-git-send-email-phil@nwl.cc>
References: <1438863876-1935-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:52238 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755663AbbHFMYi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 08:24:38 -0400
In-Reply-To: <1438863876-1935-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was working before, but only if realloc a) succeeded and b) did not
move the buffer to a different location. ''**buf = **new_buf' then
writes the value of *new_buf's first field into that of *buf.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 misc/ss.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/misc/ss.c b/misc/ss.c
index f4c828c..af5a3c2 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -597,7 +597,7 @@ static int find_entry(unsigned ino, char **buf, int type)
 					fprintf(stderr, "ss: failed to malloc buffer\n");
 					abort();
 				}
-				**buf = **new_buf;
+				*buf = *new_buf;
 				buf_len = new_buf_len;
 				continue;
 			} else {
-- 
2.1.2
