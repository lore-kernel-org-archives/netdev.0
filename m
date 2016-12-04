From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/3] bpf: remove type arg from __is_valid_{,xdp_}access
Date: Sun,  4 Dec 2016 23:19:39 +0100
Message-ID: <b3632e88bd36b0d3908fc536e533d87e0e48a38d.1480889473.git.daniel@iogearbox.net>
References: <cover.1480889473.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40039 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751075AbcLDWTo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Dec 2016 17:19:44 -0500
In-Reply-To: <cover.1480889473.git.daniel@iogearbox.net>
In-Reply-To: <cover.1480889473.git.daniel@iogearbox.net>
References: <cover.1480889473.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit d691f9e8d440 ("bpf: allow programs to write to certain skb
fields") pushed access type check outside of __is_valid_access()
to have different restrictions for socket filters and tc programs.
type is thus not used anymore within __is_valid_access() and should
be removed as a function argument. Same for __is_valid_xdp_access()
introduced by 6a773a15a1e8 ("bpf: add XDP prog type for early driver
filter").

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 56b4358..b751202 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2748,7 +2748,7 @@ static unsigned long bpf_xdp_copy(void *dst_buff, const void *src_buff,
 	}
 }
 
-static bool __is_valid_access(int off, int size, enum bpf_access_type type)
+static bool __is_valid_access(int off, int size)
 {
 	if (off < 0 || off >= sizeof(struct __sk_buff))
 		return false;
@@ -2782,7 +2782,7 @@ static bool sk_filter_is_valid_access(int off, int size,
 		}
 	}
 
-	return __is_valid_access(off, size, type);
+	return __is_valid_access(off, size);
 }
 
 static bool lwt_is_valid_access(int off, int size,
@@ -2815,7 +2815,7 @@ static bool lwt_is_valid_access(int off, int size,
 		break;
 	}
 
-	return __is_valid_access(off, size, type);
+	return __is_valid_access(off, size);
 }
 
 static bool sock_filter_is_valid_access(int off, int size,
@@ -2833,11 +2833,9 @@ static bool sock_filter_is_valid_access(int off, int size,
 
 	if (off < 0 || off + size > sizeof(struct bpf_sock))
 		return false;
-
 	/* The verifier guarantees that size > 0. */
 	if (off % size != 0)
 		return false;
-
 	if (size != sizeof(__u32))
 		return false;
 
@@ -2910,11 +2908,10 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 		break;
 	}
 
-	return __is_valid_access(off, size, type);
+	return __is_valid_access(off, size);
 }
 
-static bool __is_valid_xdp_access(int off, int size,
-				  enum bpf_access_type type)
+static bool __is_valid_xdp_access(int off, int size)
 {
 	if (off < 0 || off >= sizeof(struct xdp_md))
 		return false;
@@ -2942,7 +2939,7 @@ static bool xdp_is_valid_access(int off, int size,
 		break;
 	}
 
-	return __is_valid_xdp_access(off, size, type);
+	return __is_valid_xdp_access(off, size);
 }
 
 void bpf_warn_invalid_xdp_action(u32 act)
-- 
1.9.3
