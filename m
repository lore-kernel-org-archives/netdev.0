From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 2/2] errqueue: include linux/time.h
Date: Mon, 12 Sep 2016 13:05:30 -0400
Message-ID: <1473699930-58865-3-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1473699930-58865-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
        john.stultz@linaro.rg, bmoses@google.com,
        Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473699930-58865-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Willem de Bruijn <willemb@google.com>

struct scm_timestamping has fields of type struct timespec. Now that
it is safe to include linux/time.h and time.h at the same time,
include linux/time.h directly in linux/errqueue.h

Without this patch, when compiling the following program after
make headers_install:

gcc -Wall -Werror -Iusr/include -c -xc - <<EOF
  #include <linux/errqueue.h>
  static struct scm_timestamping tss;
  int main(void) { tss.ts[0].tv_sec = 1; return 0; }
EOF

gcc gives this error:

  In file included from <stdin>:1:0:
  usr/include/linux/errqueue.h:33:18: error: array type has incomplete element type
    struct timespec ts[3];

Reported-by: Brooks Moses <bmoses@google.com>
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/uapi/linux/errqueue.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/uapi/linux/errqueue.h b/include/uapi/linux/errqueue.h
index 07bdce1..abafec8 100644
--- a/include/uapi/linux/errqueue.h
+++ b/include/uapi/linux/errqueue.h
@@ -1,6 +1,7 @@
 #ifndef _UAPI_LINUX_ERRQUEUE_H
 #define _UAPI_LINUX_ERRQUEUE_H
 
+#include <linux/time.h>
 #include <linux/types.h>
 
 struct sock_extended_err {
-- 
2.8.0.rc3.226.g39d4020
