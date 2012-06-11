From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Subject: [PATCH 3/4] bitops: Introduce generic set_bit_le()
Date: Mon, 11 Jun 2012 21:31:01 +0900
Message-ID: <20120611213101.5969fde5.yoshikawa.takuya@oss.ntt.co.jp>
References: <20120611212735.f92ea521.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, grundler@parisc-linux.org,
	avi@redhat.com, mtosatti@redhat.com,
	linux-net-drivers@solarflare.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org,
	kvm@vger.kernel.org, takuya.yoshikawa@gmail.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120611212735.f92ea521.yoshikawa.takuya@oss.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>

Needed to replace test_and_set_bit_le() in virt/kvm/kvm_main.c which is
being used for this missing function.

Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Cc: Arnd Bergmann <arnd@arndb.de>
---
 include/asm-generic/bitops/le.h |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/include/asm-generic/bitops/le.h b/include/asm-generic/bitops/le.h
index f95c663..3e72143 100644
--- a/include/asm-generic/bitops/le.h
+++ b/include/asm-generic/bitops/le.h
@@ -54,6 +54,11 @@ static inline int test_bit_le(int nr, const void *addr)
 	return test_bit(nr ^ BITOP_LE_SWIZZLE, addr);
 }
 
+static inline void set_bit_le(int nr, void *addr)
+{
+	set_bit(nr ^ BITOP_LE_SWIZZLE, addr);
+}
+
 static inline void __set_bit_le(int nr, void *addr)
 {
 	__set_bit(nr ^ BITOP_LE_SWIZZLE, addr);
-- 
1.7.5.4
