From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH 3/3] vhost: fix get_user_pages_fast error handling
Date: Tue, 23 Feb 2010 18:57:58 +0200
Message-ID: <82ba8c97ce55dd4bf9972ad755961cd14e6a0938.1266943453.git.mst@redhat.com>
References: <cover.1266943453.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Miller <davem@davemloft.net>,
	ma
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1266943453.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

get_user_pages_fast returns number of pages on success, negative value
on failure, but never 0. Fix vhost code to match this logic.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 drivers/vhost/vhost.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
index d4f8fdf..d003504 100644
--- a/drivers/vhost/vhost.c
+++ b/drivers/vhost/vhost.c
@@ -646,8 +646,9 @@ static int set_bit_to_user(int nr, void __user *addr)
 	int bit = nr + (log % PAGE_SIZE) * 8;
 	int r;
 	r = get_user_pages_fast(log, 1, 1, &page);
-	if (r)
+	if (r < 0)
 		return r;
+	BUG_ON(r != 1);
 	base = kmap_atomic(page, KM_USER0);
 	set_bit(bit, base);
 	kunmap_atomic(base, KM_USER0);
-- 
1.7.0.18.g0d53a5
