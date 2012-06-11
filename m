From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Subject: [PATCH 4/4] KVM: Replace test_and_set_bit_le() in
 mark_page_dirty_in_slot() with set_bit_le()
Date: Mon, 11 Jun 2012 21:32:21 +0900
Message-ID: <20120611213221.a48fc664.yoshikawa.takuya@oss.ntt.co.jp>
References: <20120611212735.f92ea521.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, grundler@parisc-linux.org,
	arnd@arndb.de, linux-net-drivers@solarflare.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arch@vger.kernel.org, kvm@vger.kernel.org,
	takuya.yoshikawa@gmail.com
To: avi@redhat.com, mtosatti@redhat.com
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <20120611212735.f92ea521.yoshikawa.takuya@oss.ntt.co.jp>
Sender: linux-arch-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>

Now that we have defined generic set_bit_le() we do not need to use
test_and_set_bit_le() for atomically setting a bit.

Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
---
 virt/kvm/kvm_main.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 02cb440..560c502 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1485,8 +1485,7 @@ void mark_page_dirty_in_slot(struct kvm *kvm, struct kvm_memory_slot *memslot,
 	if (memslot && memslot->dirty_bitmap) {
 		unsigned long rel_gfn = gfn - memslot->base_gfn;
 
-		/* TODO: introduce set_bit_le() and use it */
-		test_and_set_bit_le(rel_gfn, memslot->dirty_bitmap);
+		set_bit_le(rel_gfn, memslot->dirty_bitmap);
 	}
 }
 
-- 
1.7.5.4
