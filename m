From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 4/4] mISDN: misc timerdev fixes
Date: Sun, 12 Oct 2008 19:11:13 -0700
Message-ID: <20081012191113.4aa0d6ef.akpm@linux-foundation.org>
References: <200809222151.m8MLp3tb031906@imap1.linux-foundation.org>
	<20080923104026.GA12535@infradead.org>
	<20080923043005.358e19e7.akpm@linux-foundation.org>
	<20081012110510.GA19600@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hch@infradead.org, kkeil@suse.de, netdev@vger.kernel.org,
	andi@firstfloor.org, ak@linux.intel.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:58354 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754343AbYJMCMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Oct 2008 22:12:12 -0400
In-Reply-To: <20081012110510.GA19600@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Sun, 12 Oct 2008 07:05:10 -0400 Christoph Hellwig <hch@infradead.org> wrote:
> 
> The bogus version which removes ->llseek just got into Linus' tree..

Well I still have this queued:

From: Andrew Morton <akpm@linux-foundation.org>

Cc: Andi Kleen <andi@firstfloor.org>
Cc: Karsten Keil <kkeil@suse.de>
Cc: Christoph Hellwig <hch@lst.de>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/isdn/mISDN/timerdev.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN drivers/isdn/mISDN/timerdev.c~misdn-misc-timerdev-fixes-fix drivers/isdn/mISDN/timerdev.c
--- a/drivers/isdn/mISDN/timerdev.c~misdn-misc-timerdev-fixes-fix
+++ a/drivers/isdn/mISDN/timerdev.c
@@ -61,7 +61,7 @@ mISDN_open(struct inode *ino, struct fil
 	init_waitqueue_head(&dev->wait);
 	filep->private_data = dev;
 	__module_get(THIS_MODULE);
-	return 0;
+	return nonseekable_open(ino, filep);
 }
 
 static int
_


So presumably whoever merged the unfixed version flubbed the fix.

If that'll fix it.  Is it sufficient?  I think so.
