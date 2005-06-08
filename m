From: Pavel Machek <pavel@ucw.cz>
Subject: [-mm] ipw2100: kill dead macros
Date: Wed, 8 Jun 2005 15:35:06 +0200
Message-ID: <20050608133506.GA3028@elf.ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: Netdev list <netdev@oss.sgi.com>,
        "James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
        Andrew Morton <akpm@zip.com.au>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

There are several never used macros in ipw2100. This removes them.

Signed-off-by: Pavel Machek <pavel@suse.cz>

--- /data/l/clean-mm/drivers/net/wireless/ipw2100.c	2005-06-08 12:11:29.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.c	2005-06-08 15:09:26.000000000 +0200
@@ -1118,7 +1074,6 @@
 {
 #define MAX_RF_KILL_CHECKS 5
 #define RF_KILL_CHECK_DELAY 40
-#define RF_KILL_CHECK_THRESHOLD 3
 
 	unsigned short value = 0;
 	u32 reg = 0;
--- /data/l/clean-mm/drivers/net/wireless/ipw2100.h	2005-06-08 12:11:29.000000000 +0200
+++ linux-mm/drivers/net/wireless/ipw2100.h	2005-06-08 15:07:31.000000000 +0200
@@ -167,15 +141,6 @@
 #define IPW_DEBUG_STATE(f, a...) IPW_DEBUG(IPW_DL_STATE | IPW_DL_ASSOC | IPW_DL_INFO, f, ## a)
 #define IPW_DEBUG_ASSOC(f, a...) IPW_DEBUG(IPW_DL_ASSOC | IPW_DL_INFO, f, ## a)
 
-
-#define VERIFY(f) \
-{ \
-  int status = 0; \
-  status = f; \
-  if(status) \
-     return status; \
-}
-
 enum {
 	IPW_HW_STATE_DISABLED = 1,
 	IPW_HW_STATE_ENABLED = 0
@@ -210,8 +175,6 @@
 	} info;
 } __attribute__ ((packed));
 
-#define	IPW_BUFDESC_LAST_FRAG 0
-
 struct ipw2100_bd {
 	u32 host_addr;
 	u32 buf_length;
@@ -648,9 +606,6 @@
 	struct semaphore adapter_sem;
 
 	wait_queue_head_t wait_command_queue;
-#if LINUX_VERSION_CODE < KERNEL_VERSION(2,6,10)
-	u32 pm_state[PM_STATE_SIZE];
-#endif
 };
 
 
@@ -761,41 +707,6 @@
 #define IPW_MEM_HOST_SHARED_TX_QUEUE_WRITE_INDEX \
     (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND)
 
-
-#if 0
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_0_BD_BASE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x00)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_0_BD_SIZE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x04)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_1_BD_BASE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x08)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_1_BD_SIZE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x0c)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_2_BD_BASE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x10)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_2_BD_SIZE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x14)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_3_BD_BASE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x18)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_3_BD_SIZE          (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x1c)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_0_READ_INDEX       (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x80)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_1_READ_INDEX       (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x84)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_2_READ_INDEX       (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x88)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_3_READ_INDEX       (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x8c)
-
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_BD_BASE(QueueNum) \
-    (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + (QueueNum<<3))
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_BD_SIZE(QueueNum) \
-    (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x0004+(QueueNum<<3))
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_READ_INDEX(QueueNum) \
-    (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x0080+(QueueNum<<2))
-
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_0_WRITE_INDEX \
-    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x00)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_1_WRITE_INDEX \
-    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x04)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_2_WRITE_INDEX \
-    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x08)
-#define IPW_MEM_HOST_SHARED_TX_QUEUE_3_WRITE_INDEX \
-    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x0c)
-#define IPW_MEM_HOST_SHARED_SLAVE_MODE_INT_REGISTER \
-    (IPW_MEM_SRAM_HOST_INTERRUPT_AREA_LOWER_BOUND + 0x78)
-
-#endif
-
 #define IPW_MEM_HOST_SHARED_ORDINALS_TABLE_1   (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x180)
 #define IPW_MEM_HOST_SHARED_ORDINALS_TABLE_2   (IPW_MEM_SRAM_HOST_SHARED_LOWER_BOUND + 0x184)
 
