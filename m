From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 00/24 for-2.6.25] DM9000 updates for 2.6.25
Date: Mon, 4 Feb 2008 16:19:40 -0800
Message-ID: <20080204161940.2fc8ca14.akpm@linux-foundation.org>
References: <20080205000159.432081941@fluff.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, daniel@caiaq.de,
	laurentp@cse-semaphore.com
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42843 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755278AbYBEAUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2008 19:20:46 -0500
In-Reply-To: <20080205000159.432081941@fluff.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 05 Feb 2008 00:01:59 +0000
Ben Dooks <ben-linux@fluff.org> wrote:

> Subject: [PATCH 00/24 for-2.6.25] DM9000 updates for 2.6.25

Holy cow.

> This patch set is a series of updates for the DM9000
> driver, to tidy-up some of the source, stop the accesses
> to the PHY and EEPROM sitting and spinning with locks
> held, and to add ethtool support.

Jeff, the immediate issue is that the driver doesn't compile on mips.  I
have the below lameo fix for it, but it appears to be wrong.  Or at least
suboptimal.

So if you're unprepared to chew on this lot (and 24 patches two weeks into the
merge window is one hell of a chew) then we do need to get that
regression fixed, at least.



From: Andrew Morton <akpm@linux-foundation.org>

mips:

drivers/net/dm9000.c: In function `dm9000_open':
drivers/net/dm9000.c:627: error: `IRQT_RISING' undeclared (first use in this function)
drivers/net/dm9000.c:627: error: (Each undeclared identifier is reported only once
drivers/net/dm9000.c:627: error: for each function it appears in.)

Cc: Daniel Mack <daniel@caiaq.de>
Cc: Russell King <rmk@arm.linux.org.uk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/dm9000.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff -puN drivers/net/dm9000.c~drivers-net-dm9000c-vague-probably-wrong-build-fix drivers/net/dm9000.c
--- a/drivers/net/dm9000.c~drivers-net-dm9000c-vague-probably-wrong-build-fix
+++ a/drivers/net/dm9000.c
@@ -113,8 +113,10 @@
 #define writesw	outsw
 #define writesl	outsl
 #define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQF_TRIGGER_HIGH)
-#else
+#elif defined(ARM)
 #define DM9000_IRQ_FLAGS	(IRQF_SHARED | IRQT_RISING)
+#else
+#define DM9000_IRQ_FLAGS	(IRQF_SHARED)
 #endif
 
 /*
_

