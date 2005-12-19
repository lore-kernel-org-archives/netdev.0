From: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Subject: [BUG][PATCH] e1000: Fix invalid memory reference
Date: Mon, 19 Dec 2005 14:36:05 -0800
Message-ID: <4807377b0512191436i5b68da0blf640e8a4922b2000@mail.gmail.com>
References: <439EA1F4.3000204@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: kaneshige.kenji@jp.fujitsu.com,
	NetDEV list <netdev@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S964881AbVLSWgI@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <439EA1F4.3000204@jp.fujitsu.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks for the patch!
Jeff, if you would be so kind as to apply this, thanks...

This patch fixes invalid memory reference in the e1000 driver which
would cause kernel panic.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Acked-by: Jesse Brandeburg <jesse.brandeburg@intel.com>

---------- Forwarded message ----------
From: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>
Date: Dec 13, 2005 2:27 AM
Subject: [BUG][PATCH] e1000: Fix invalid memory reference
To: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Cc: Andrew Morton <akpm@osdl.org>


Hi,

I encountered a kernel panic which was caused by the invalid memory
access by e1000 driver. The following patch fixes this issue.

Thanks,
Kenji Kaneshige


This patch fixes invalid memory reference in the e1000 driver which
would cause kernel panic.

Signed-off-by: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>

 drivers/net/e1000/e1000_param.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

Index: linux-2.6.15-rc5/drivers/net/e1000/e1000_param.c
===================================================================
--- linux-2.6.15-rc5.orig/drivers/net/e1000/e1000_param.c
+++ linux-2.6.15-rc5/drivers/net/e1000/e1000_param.c
@@ -545,7 +545,7 @@ e1000_check_fiber_options(struct e1000_a
 static void __devinit
 e1000_check_copper_options(struct e1000_adapter *adapter)
 {
-       int speed, dplx;
+       int speed, dplx, an;
        int bd = adapter->bd_number;

        { /* Speed */
@@ -641,8 +641,12 @@ e1000_check_copper_options(struct e1000_
                                         .p = an_list }}
                };

-               int an = AutoNeg[bd];
-               e1000_validate_option(&an, &opt, adapter);
+               if (num_AutoNeg > bd) {
+                       an = AutoNeg[bd];
+                       e1000_validate_option(&an, &opt, adapter);
+               } else {
+                       an = opt.def;
+               }
                adapter->hw.autoneg_advertised = an;
        }

