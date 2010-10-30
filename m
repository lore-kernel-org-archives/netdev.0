From: Vasiliy Kulikov <segooon@gmail.com>
Subject: [PATCH] net: core: scm: fix information leak to userland
Date: Sat, 30 Oct 2010 18:26:35 +0400
Message-ID: <1288448796-6147-1-git-send-email-segooon@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tejun Heo <tj@kernel.org>,
	"Serge E. Hallyn" <serge@hallyn.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Structure cmsghdr is copied to userland with padding bytes
unitialized on architectures where __kernel_size_t is unsigned long.
It leads to leaking of contents of kernel stack memory.

Signed-off-by: Vasiliy Kulikov <segooon@gmail.com>
---
 Compile tested.

 net/core/scm.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/core/scm.c b/net/core/scm.c
index 413cab8..a4a9b70 100644
--- a/net/core/scm.c
+++ b/net/core/scm.c
@@ -233,6 +233,7 @@ int put_cmsg(struct msghdr * msg, int level, int type, int len, void *data)
 		msg->msg_flags |= MSG_CTRUNC;
 		cmlen = msg->msg_controllen;
 	}
+	memset(&cmhdr, 0, sizeof(cmhdr));
 	cmhdr.cmsg_level = level;
 	cmhdr.cmsg_type = type;
 	cmhdr.cmsg_len = cmlen;
-- 
1.7.0.4
