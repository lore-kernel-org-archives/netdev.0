From: "Kirill A. Shutsemov" <kirill@shutemov.name>
Subject: [PATCH] netlink: fix gcc -Wconversion compilation warning
Date: Mon, 13 Dec 2010 19:05:13 +0200
Message-ID: <1292259913-9911-1-git-send-email-kirill@shutemov.name>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Dmitry V. Levin" <ldv@altlinux.org>, linux-kernel@vger.kernel.org,
	"Kirill A. Shutemov" <kirill@shutemov.name>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry V. Levin <ldv@altlinux.org>

$ cat << EOF | gcc -Wconversion -xc -S -o/dev/null -
unsigned f(void) {return NLMSG_HDRLEN;}
EOF
<stdin>: In function 'f':
<stdin>:3:26: warning: negative integer implicitly converted to unsigned type

Signed-off-by: Dmitry V. Levin <ldv@altlinux.org>
Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>
---
 include/linux/netlink.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/include/linux/netlink.h b/include/linux/netlink.h
index 1235669..e2b9e63 100644
--- a/include/linux/netlink.h
+++ b/include/linux/netlink.h
@@ -70,7 +70,7 @@ struct nlmsghdr {
    Check		NLM_F_EXCL
  */
 
-#define NLMSG_ALIGNTO	4
+#define NLMSG_ALIGNTO	4U
 #define NLMSG_ALIGN(len) ( ((len)+NLMSG_ALIGNTO-1) & ~(NLMSG_ALIGNTO-1) )
 #define NLMSG_HDRLEN	 ((int) NLMSG_ALIGN(sizeof(struct nlmsghdr)))
 #define NLMSG_LENGTH(len) ((len)+NLMSG_ALIGN(NLMSG_HDRLEN))
-- 
1.7.3.3
