From: Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH] net: b43legacy: fix compile error
Date: Mon, 25 Oct 2010 13:59:51 -0500
Message-ID: <4CC5D3A7.3080709@lwfinger.net>
References: <1288017690-31248-1-git-send-email-arnd@arndnet.de> <4CC5A301.1080606@lwfinger.net> <4CC5CBC4.7060308@arndnet.de> <4CC5CE47.2020607@lwfinger.net> <4CC5D01C.20804@arndnet.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020507030607040009030501"
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Arnd Hannemann <arnd-BCMAnToX5e2ELgA04lAiVw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4CC5D01C.20804-BCMAnToX5e2ELgA04lAiVw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------020507030607040009030501
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 10/25/2010 01:44 PM, Arnd Hannemann wrote:
> Am 25.10.2010 20:36, schrieb Larry Finger:
>> On 10/25/2010 01:26 PM, Arnd Hannemann wrote:
>>> Am 25.10.2010 17:32, schrieb Larry Finger:
>>>> On 10/25/2010 09:41 AM, Arnd Hannemann wrote:
>>>>> On todays linus tree the following compile error happened to me:
>>>>>
>>>>>   CC [M]  drivers/net/wireless/b43legacy/xmit.o
>>>>> In file included from include/net/dst.h:11,
>>>>>                  from drivers/net/wireless/b43legacy/xmit.c:31:
>>>>> include/net/dst_ops.h:28: error: expected ':', ',', ';', '}' or '__attribute__' before '____cacheline_aligned_in_smp'
>>>>> include/net/dst_ops.h: In function 'dst_entries_get_fast':
>>>>> include/net/dst_ops.h:33: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>>> include/net/dst_ops.h: In function 'dst_entries_get_slow':
>>>>> include/net/dst_ops.h:41: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>>> include/net/dst_ops.h: In function 'dst_entries_add':
>>>>> include/net/dst_ops.h:49: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>>> include/net/dst_ops.h: In function 'dst_entries_init':
>>>>> include/net/dst_ops.h:55: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>>> include/net/dst_ops.h: In function 'dst_entries_destroy':
>>>>> include/net/dst_ops.h:60: error: 'struct dst_ops' has no member named 'pcpuc_entries'
>>>>> make[4]: *** [drivers/net/wireless/b43legacy/xmit.o] Error 1
>>>>> make[3]: *** [drivers/net/wireless/b43legacy] Error 2
>>>>> make[2]: *** [drivers/net/wireless] Error 2
>>>>> make[1]: *** [drivers/net] Error 2
>>>>> make: *** [drivers] Error 2
>>>>>
>>>>> This patch fixes this issue by adding "linux/cache.h" as an include to
>>>>> "include/net/dst_ops.h".
>>>>
>>>> Strange. Compiling b43legacy from the linux-2.6.git tree (git describe is
>>>> v2.6.36-4464-g229aebb) works fine on x86_64. I wonder what is different.
>>>
>>> Exactly the same git describe here.
>>> Maybe your arch includes cache.h already, in my case its a compile for ARM (shmobile).
>>
>> That probably makes the difference. Using Eric's fix that removes the #include
>> <linux/dst.h> should be better. Does it work for you?
>>
>> There are probably a lot more of the system includes that may not be needed. If
>> I send you a patch removing them, could you test?
> 
> As it turns out my card is not supported by b43legacy, but compilation testing,
> sure I can test that.

If it is a Broadcom card, it is likely handled by b43.

Attached is a trial removal of a number of include statements. Does it compile?

Larry

--------------020507030607040009030501
Content-Type: text/plain;
 name="b43legacy_remove_dst_h"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="b43legacy_remove_dst_h"

Index: linux-2.6/drivers/net/wireless/b43legacy/dma.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/b43legacy/dma.c
+++ linux-2.6/drivers/net/wireless/b43legacy/dma.c
@@ -33,13 +33,6 @@
 #include "debugfs.h"
 #include "xmit.h"
 
-#include <linux/dma-mapping.h>
-#include <linux/pci.h>
-#include <linux/delay.h>
-#include <linux/skbuff.h>
-#include <linux/slab.h>
-#include <net/dst.h>
-
 /* 32bit DMA ops. */
 static
 struct b43legacy_dmadesc_generic *op32_idx2desc(
Index: linux-2.6/drivers/net/wireless/b43legacy/main.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/b43legacy/main.c
+++ linux-2.6/drivers/net/wireless/b43legacy/main.c
@@ -29,20 +29,8 @@
  *
  */
 
-#include <linux/delay.h>
-#include <linux/init.h>
-#include <linux/moduleparam.h>
-#include <linux/if_arp.h>
 #include <linux/etherdevice.h>
 #include <linux/firmware.h>
-#include <linux/wireless.h>
-#include <linux/workqueue.h>
-#include <linux/sched.h>
-#include <linux/skbuff.h>
-#include <linux/dma-mapping.h>
-#include <linux/slab.h>
-#include <net/dst.h>
-#include <asm/unaligned.h>
 
 #include "b43legacy.h"
 #include "main.h"
Index: linux-2.6/drivers/net/wireless/b43legacy/xmit.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/b43legacy/xmit.c
+++ linux-2.6/drivers/net/wireless/b43legacy/xmit.c
@@ -28,8 +28,6 @@
 
 */
 
-#include <net/dst.h>
-
 #include "xmit.h"
 #include "phy.h"
 #include "dma.h"
Index: linux-2.6/drivers/net/wireless/b43legacy/phy.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/b43legacy/phy.c
+++ linux-2.6/drivers/net/wireless/b43legacy/phy.c
@@ -29,12 +29,6 @@
 
 */
 
-#include <linux/delay.h>
-#include <linux/pci.h>
-#include <linux/sched.h>
-#include <linux/slab.h>
-#include <linux/types.h>
-
 #include "b43legacy.h"
 #include "phy.h"
 #include "main.h"
Index: linux-2.6/drivers/net/wireless/b43legacy/pio.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/b43legacy/pio.c
+++ linux-2.6/drivers/net/wireless/b43legacy/pio.c
@@ -28,10 +28,6 @@
 #include "main.h"
 #include "xmit.h"
 
-#include <linux/delay.h>
-#include <linux/slab.h>
-
-
 static void tx_start(struct b43legacy_pioqueue *queue)
 {
 	b43legacy_pio_write(queue, B43legacy_PIO_TXCTL,
Index: linux-2.6/drivers/net/wireless/b43legacy/radio.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/b43legacy/radio.c
+++ linux-2.6/drivers/net/wireless/b43legacy/radio.c
@@ -29,8 +29,6 @@
 
 */
 
-#include <linux/delay.h>
-
 #include "b43legacy.h"
 #include "main.h"
 #include "phy.h"
Index: linux-2.6/drivers/net/wireless/b43legacy/sysfs.c
===================================================================
--- linux-2.6.orig/drivers/net/wireless/b43legacy/sysfs.c
+++ linux-2.6/drivers/net/wireless/b43legacy/sysfs.c
@@ -29,8 +29,6 @@
 #include "phy.h"
 #include "radio.h"
 
-#include <linux/capability.h>
--------------020507030607040009030501--
