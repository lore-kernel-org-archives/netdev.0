From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net: sfc: avoid -Wtype-limits warning
Date: Wed, 15 Jun 2016 22:31:10 +0200
Message-ID: <20160615203122.3574513-1-arnd@arndb.de>
Cc: Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Martin Habets <mhabets@solarflare.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Solarflare linux maintainers <linux-net-drivers@solarflare.com>,
	Edward Cree <ecree@solarflare.com>,
	Bert Kenward <bkenward@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When building with -Wextra, we get a harmless warning from the
EFX_EXTRACT_OWORD32 macro:

ethernet/sfc/farch.c: In function 'efx_farch_test_registers':
ethernet/sfc/farch.c:119:30: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
ethernet/sfc/farch.c:124:144: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
ethernet/sfc/farch.c:124:392: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]
ethernet/sfc/farch.c:124:731: error: comparison of unsigned expression < 0 is always false [-Werror=type-limits]

The macro and the caller are both correct, but we can avoid the
warning by changing the index variable to a signed type.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/ethernet/sfc/farch.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/sfc/farch.c b/drivers/net/ethernet/sfc/farch.c
index 133e9e35be9e..4c83739d158f 100644
--- a/drivers/net/ethernet/sfc/farch.c
+++ b/drivers/net/ethernet/sfc/farch.c
@@ -104,7 +104,8 @@ int efx_farch_test_registers(struct efx_nic *efx,
 			     const struct efx_farch_register_test *regs,
 			     size_t n_regs)
 {
-	unsigned address = 0, i, j;
+	unsigned address = 0;
+	int i, j;
 	efx_oword_t mask, imask, original, reg, buf;
 
 	for (i = 0; i < n_regs; ++i) {
-- 
2.9.0
