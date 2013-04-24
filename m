From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] VSOCK: Drop bogus __init annotation from vsock_init_tables()
Date: Wed, 24 Apr 2013 11:40:55 +0200
Message-ID: <1366796455-2520-1-git-send-email-geert@linux-m68k.org>
Cc: linux-kernel@vger.kernel.org,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: Andy King <acking@vmware.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If gcc (e.g. 4.1.2) decides not to inline vsock_init_tables(), this will
cause a section mismatch:

WARNING: net/vmw_vsock/vsock.o(.text+0x1bc): Section mismatch in reference from the function __vsock_core_init() to the function .init.text:vsock_init_tables()
The function __vsock_core_init() references
the function __init vsock_init_tables().
This is often because __vsock_core_init lacks a __init
annotation or the annotation of vsock_init_tables is wrong.

This may cause crashes if VSOCKETS=y and VMWARE_VMCI_VSOCKETS=m.

Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 net/vmw_vsock/af_vsock.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/vmw_vsock/af_vsock.c b/net/vmw_vsock/af_vsock.c
index 7f93e2a..2e330e8 100644
--- a/net/vmw_vsock/af_vsock.c
+++ b/net/vmw_vsock/af_vsock.c
@@ -165,7 +165,7 @@ static struct list_head vsock_bind_table[VSOCK_HASH_SIZE + 1];
 static struct list_head vsock_connected_table[VSOCK_HASH_SIZE];
 static DEFINE_SPINLOCK(vsock_table_lock);
 
-static __init void vsock_init_tables(void)
+static void vsock_init_tables(void)
 {
 	int i;
 
-- 
1.7.0.4
