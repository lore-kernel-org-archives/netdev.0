From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] af_unix: Use designated initializers
Date: Tue, 4 Apr 2017 22:12:09 -0700
Message-ID: <20170405051209.GA15324@beast>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Miklos Szeredi <mszeredi@redhat.com>,
        Al Viro <viro@zeniv.linux.org.uk>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Kees Cook <keescook@chromium.org>,
        Vladimir Davydov <vdavydov.dev@gmail.com>,
        Andrey Vagin <avagin@openvz.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Prepare to mark sensitive kernel structures for randomization by making
sure they're using designated initializers. These were identified during
allyesconfig builds of x86, arm, and arm64, and the initializer fixes
were extracted from grsecurity. In this case, NULL initialize with { }
instead of undesignated NULLs.

Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/unix/af_unix.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 928691c43408..6a7fe7660551 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -996,7 +996,7 @@ static int unix_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 	unsigned int hash;
 	struct unix_address *addr;
 	struct hlist_head *list;
-	struct path path = { NULL, NULL };
+	struct path path = { };
 
 	err = -EINVAL;
 	if (sunaddr->sun_family != AF_UNIX)
-- 
2.7.4


-- 
Kees Cook
Pixel Security
