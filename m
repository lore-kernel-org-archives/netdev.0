From: David Miller <davem@davemloft.net>
Subject: Re: [PATC] sctp: various fixes
Date: Sat, 19 Jul 2008 22:40:47 -0700 (PDT)
Message-ID: <20080719.224047.228019059.davem@davemloft.net>
References: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
	<20080718.230833.22196996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53368
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750769AbYGTFkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jul 2008 01:40:47 -0400
In-Reply-To: <20080718.230833.22196996.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Fri, 18 Jul 2008 23:08:33 -0700 (PDT)

> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Sat, 19 Jul 2008 00:26:45 -0400
> 
> > This is a bunch of SCTP fixes that have accumlated over the past week or
> > so. 
> 
> All applied, thanks Vlad.

Vlad, I had to add the following fix to the tree in order
to unbreak the build when CONFIG_HIGHMEM is enabled.

highmem: Export totalhigh_pages.

Hash et al. sizing code in SCTP wants to make the
calculation totalram_pages - totalhigh_pages, just
like TCP.  But this requires an export for the
CONFIG_HIGHMEM case to work.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/mm/highmem.c b/mm/highmem.c
index 7da4a7b..e16e152 100644
--- a/mm/highmem.c
+++ b/mm/highmem.c
@@ -40,6 +40,7 @@
 #ifdef CONFIG_HIGHMEM
 
 unsigned long totalhigh_pages __read_mostly;
+EXPORT_SYMBOL(totalhigh_pages);
 
 unsigned int nr_free_highpages (void)
 {
