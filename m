From: David Howells <dhowells@redhat.com>
Subject: [PATCH 2/5] [AFS]: Fix memory leak in SRXAFSCB_GetCapabilities
Date: Thu, 03 May 2007 10:53:20 +0100
Message-ID: <20070503095320.26912.67210.stgit@warthog.cambridge.redhat.com>
References: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, kaber@trash.net, dhowells@redhat.com
To: akpm@osdl.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070503095315.26912.24270.stgit@warthog.cambridge.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The interface array is not freed on exit.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: David Howells <dhowells@redhat.com>
---

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

