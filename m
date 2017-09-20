From: Kees Cook <keescook@chromium.org>
Subject: [PATCH v3 22/31] sctp: Copy struct sctp_sock.autoclose to userspace using put_user()
Date: Wed, 20 Sep 2017 13:45:28 -0700
Message-ID: <1505940337-79069-23-git-send-email-keescook@chromium.org>
References: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Cc: Kees Cook <keescook@chromium.org>,
	David Windsor <dave@nullcore.net>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	kernel-hardening@lists.openwall.com
To: linux-kernel@vger.kernel.org
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1505940337-79069-1-git-send-email-keescook@chromium.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

From: David Windsor <dave@nullcore.net>

The autoclose field can be copied with put_user(), so there is no need to
use copy_to_user(). In both cases, hardened usercopy is being bypassed
since the size is constant, and not open to runtime manipulation.

This patch is verbatim from Brad Spengler/PaX Team's PAX_USERCOPY
whitelisting code in the last public patch of grsecurity/PaX based on my
understanding of the code. Changes or omissions from the original code are
mine and don't reflect the original grsecurity/PaX code.

Signed-off-by: David Windsor <dave@nullcore.net>
[kees: adjust commit log]
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: linux-sctp@vger.kernel.org
Cc: netdev@vger.kernel.org
Signed-off-by: Kees Cook <keescook@chromium.org>
---
 net/sctp/socket.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sctp/socket.c b/net/sctp/socket.c
index aa4f86d64545..e070c0934638 100644
--- a/net/sctp/socket.c
+++ b/net/sctp/socket.c
@@ -4893,7 +4893,7 @@ static int sctp_getsockopt_autoclose(struct sock *sk, int len, char __user *optv
 	len = sizeof(int);
 	if (put_user(len, optlen))
 		return -EFAULT;
-	if (copy_to_user(optval, &sctp_sk(sk)->autoclose, sizeof(int)))
+	if (put_user(sctp_sk(sk)->autoclose, (int __user *)optval))
 		return -EFAULT;
 	return 0;
 }
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
