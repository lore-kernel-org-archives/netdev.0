From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] net/tulip: don't warn about unknown ARM architecture
Date: Fri, 30 Jan 2015 22:58:19 +0100
Message-ID: <1780413.LLpv9s01CB@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ARM has 32-byte cache lines, which according to the comment in
the init registers function seems to work best with the default
value of 0x4800 that is also used on sparc and parisc.

This adds ARM to the same list, to use that default but no
longer warn about it.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>

diff --git a/drivers/net/ethernet/dec/tulip/winbond-840.c b/drivers/net/ethernet/dec/tulip/winbond-840.c
index 6aa887e0e1cb..9beb3d34d4ba 100644
--- a/drivers/net/ethernet/dec/tulip/winbond-840.c
+++ b/drivers/net/ethernet/dec/tulip/winbond-840.c
@@ -904,7 +904,7 @@ static void init_registers(struct net_device *dev)
 	}
 #elif defined(__powerpc__) || defined(__i386__) || defined(__alpha__) || defined(__ia64__) || defined(__x86_64__)
 	i |= 0xE000;
-#elif defined(CONFIG_SPARC) || defined (CONFIG_PARISC)
+#elif defined(CONFIG_SPARC) || defined (CONFIG_PARISC) || defined(CONFIG_ARM)
 	i |= 0x4800;
 #else
 #warning Processor architecture undefined
