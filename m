From: Patrick McHardy <kaber@trash.net>
Subject: [AFS 02/04]: Fix memory leak in SRXAFSCB_GetCapabilities
Date: Thu,  3 May 2007 02:04:16 +0200 (MEST)
Message-ID: <20070503000258.30775.91148.sendpatchset@localhost.localdomain>
References: <20070503000256.30775.81929.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	howells@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48179 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767270AbXECAER (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 20:04:17 -0400
In-Reply-To: <20070503000256.30775.81929.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[AFS]: Fix memory leak in SRXAFSCB_GetCapabilities

The interface array is not freed on exit.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit cef7f64469d521dd1dcb991e247ad02e84c3051c
tree bf5b8cd7a7e31053eaf826037c0b9fc97a69cd93
parent 831e920626706afd5ced0c72ca15c8af340bc157
author Patrick McHardy <kaber@trash.net> Wed, 02 May 2007 20:19:04 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 02 May 2007 20:19:04 +0200

 fs/afs/cmservice.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/afs/cmservice.c b/fs/afs/cmservice.c
index 6685f4c..d5b2ad6 100644
--- a/fs/afs/cmservice.c
+++ b/fs/afs/cmservice.c
@@ -443,6 +443,7 @@ static void SRXAFSCB_GetCapabilities(struct work_struct *work)
 			reply.ia.netmask[loop] = ifs[loop].netmask.s_addr;
 			reply.ia.mtu[loop] = htonl(ifs[loop].mtu);
 		}
+		kfree(ifs);
 	}
 
 	reply.cap.capcount = htonl(1);
