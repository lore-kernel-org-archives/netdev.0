From: Sergei Trofimovich <slyich@gmail.com>
Subject: [PATCH] tcp: properly initialize tcp memory limits part 2 (fix nfs regression)
Date: Fri,  2 Mar 2012 10:56:38 +0300
Message-ID: <1330674998-16704-1-git-send-email-slyich@gmail.com>
Cc: netdev@vger.kernel.org, Sergei Trofimovich <slyfox@gentoo.org>,
	Jason Wang <jasowang@redhat.com>,
	Glauber Costa <glommer@parallels.com>,
	"David S. Miller" <davem@davemloft.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Trofimovich <slyfox@gentoo.org>

The commit introduced NFS file transfer hangup (proved by bisection).
> Commit 4acb4190 tries to fix the using uninitialized value
> introduced by commit 3dc43e3,  but it would make the
> per-socket memory limits too small.
>
> This patch fixes this and also remove the redundant codes
> introduced in 4acb4190.

The change looks like a typo (division flipped to multiplication):
> limit = nr_free_buffer_pages() / 8;
> limit = nr_free_buffer_pages() << (PAGE_SHIFT - 10);

Patch restores division.

CC: Jason Wang <jasowang@redhat.com>
CC: Glauber Costa <glommer@parallels.com>
CC: David S. Miller <davem@davemloft.net>
Signed-off-by: Sergei Trofimovich <slyfox@gentoo.org>
Tested-by: Sergei Trofimovich <slyfox@gentoo.org>
---
 net/ipv4/tcp.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 22ef5f9..b11667b 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3299,7 +3299,7 @@ void __init tcp_init(void)
 
 	tcp_init_mem(&init_net);
 	/* Set per-socket limits to no more than 1/128 the pressure threshold */
-	limit = nr_free_buffer_pages() << (PAGE_SHIFT - 10);
+	limit = nr_free_buffer_pages() >> (PAGE_SHIFT - 10);
 	limit = max(limit, 128UL);
 	max_share = min(4UL*1024*1024, limit);
 
-- 
1.7.8.5
