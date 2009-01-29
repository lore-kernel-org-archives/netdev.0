From: Parag Warudkar <parag.lkml@gmail.com>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Wed, 28 Jan 2009 20:49:18 -0500 (EST)
Message-ID: <alpine.DEB.2.00.0901282049040.5026@parag-desktop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901281636270.3123@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Parag Warudkar <parag.lkml@gmail.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:9948 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753104AbZA2Bta (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2009 20:49:30 -0500
In-Reply-To: <alpine.LFD.2.00.0901281636270.3123@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, 28 Jan 2009, Linus Torvalds wrote:
 
> For example, if we get the "dev->current_state" cache wrong, then we may 
> not actually end up changing it when we should, because we think we 
> already match the target state. I don't _think_ that is it, but that's the 
> kind of thing that could happen.
> 
> Can you do a
> 
> 	lspci -vvxxx -s [tg3-device]
> 
> before-and-after suspend? Is there some state that looks like it got 
> corrupted?

Sure, diff -u below. There are differences but not sure if they are 
abnormal or expected.

Also, BTW, reverting the only tg3 specific commit - 
commit 9e9fd12dc0679643c191fc9795a3021807e77de4
Author: Matt Carlson <mcarlson@broadcom.com>
Date:   Mon Jan 19 16:57:45 2009 -0800

    tg3: Fix firmware loading

did not help.

parag@parag-desktop:~$ diff -u lspci-pre-suspend lspci-post-suspend
--- lspci-pre-suspend   2009-01-28 20:35:37.070584068 -0500
+++ lspci-post-suspend  2009-01-28 20:36:56.922471408 -0500
@@ -12,7 +12,7 @@
        Capabilities: [50] Vital Product Data <?>
        Capabilities: [58] Vendor Specific Information <?>
        Capabilities: [e8] Message Signalled Interrupts: Mask- 64bit+ 
Queue=0/0 Enable+
-               Address: 00000000fee0f00c  Data: 41c9
+               Address: 00000000fee0f00c  Data: 41d1
        Capabilities: [d0] Express (v1) Endpoint, MSI 00
                DevCap: MaxPayload 128 bytes, PhantFunc 0, Latency L0s 
<4us, L1 unlimited
                        ExtTag+ AttnBtn- AttnInd- PwrInd- RBE+ FLReset-
@@ -36,15 +36,15 @@
 20: 00 00 00 00 00 00 00 00 00 00 00 00 3c 10 07 13
 30: 00 00 04 20 48 00 00 00 00 00 00 00 03 01 00 00
 40: 00 00 00 00 00 00 00 00 01 50 03 c0 08 20 00 64
-50: 03 58 fc 00 00 00 00 78 09 e8 78 00 7d c9 08 78
-60: 00 00 00 00 00 00 00 00 98 02 02 a0 00 00 18 76
-70: f2 10 00 00 c0 00 00 00 2c 00 00 00 00 00 00 00
-80: 3c 10 07 13 00 00 00 00 34 00 13 04 82 70 08 fc
-90: 19 be 00 01 00 00 00 b7 00 00 00 00 14 00 00 00
-a0: 00 00 00 00 4c 01 00 00 00 00 00 00 3e 01 00 00
-b0: 00 00 00 00 00 00 00 36 00 00 00 00 00 00 00 00
+50: 03 58 fc 00 00 00 00 78 09 e8 78 00 7e cb 08 a8
+60: 00 00 00 00 00 00 00 00 9a 02 02 a0 00 00 00 10
+70: 72 10 00 00 c0 00 00 00 2c 00 00 00 00 00 00 00
+80: 3c 10 07 13 00 00 00 00 00 00 00 00 fe 70 08 fc
+90: 11 be 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+a0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
+b0: 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
 c0: 00 00 00 00 00 80 00 00 0e 00 00 00 00 00 00 00
 d0: 10 00 01 00 a0 8f 00 00 00 50 10 00 11 64 03 00
 e0: 40 00 11 10 00 00 00 00 05 d0 81 00 0c f0 e0 fe
-f0: 00 00 00 00 c9 41 00 00 00 00 00 00 00 00 00 00
+f0: 00 00 00 00 d1 41 00 00 00 00 00 00 00 00 00 00


Parag
