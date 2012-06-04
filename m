From: Joe Perches <joe@perches.com>
Subject: [PATCH] net/9p: Add __force to cast of __user pointer
Date: Mon, 04 Jun 2012 10:16:14 -0700
Message-ID: <1338830174.15683.2.camel@joe2Laptop>
References: <4b3738493b23bc386d3372012faa8cd3672a138d.1338780551.git.joe@perches.com>
	 <1338825881.3979.203.camel@deadeye>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:40617 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751414Ab2FDRQQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jun 2012 13:16:16 -0400
In-Reply-To: <1338825881.3979.203.camel@deadeye>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A recent commit that removed unnecessary casts of pointers
to the same type uncovered a missing __force cast.

Add it.

Reported by: Ben Hutchings <bhutchings@solarflare.com>
Signed-off-by: Joe Perches <joe@perches.com>
---
 net/9p/client.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/9p/client.c b/net/9p/client.c
index 5cbea90..8260f13 100644
--- a/net/9p/client.c
+++ b/net/9p/client.c
@@ -1548,7 +1548,7 @@ p9_client_read(struct p9_fid *fid, char *data, char __user *udata, u64 offset,
 			kernel_buf = 1;
 			indata = data;
 		} else
-			indata = udata;
+			indata = (__force char *)udata;
 		/*
 		 * response header len is 11
 		 * PDU Header(7) + IO Size (4)
