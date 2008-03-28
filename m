From: David Miller <davem@davemloft.net>
Subject: Re: [patch 1/4] drivers/atm/firestream.c: suppress uninitialized
 var warning
Date: Fri, 28 Mar 2008 16:20:17 -0700 (PDT)
Message-ID: <20080328.162017.169462194.davem@davemloft.net>
References: <200803282137.m2SLbTJl011626@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chas@cmf.nrl.navy.mil, jeff@garzik.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35751
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755202AbYC1XUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 19:20:20 -0400
In-Reply-To: <200803282137.m2SLbTJl011626@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@linux-foundation.org
Date: Fri, 28 Mar 2008 14:37:29 -0700

> From: Andrew Morton <akpm@linux-foundation.org>
> 
> drivers/atm/firestream.c: In function 'fs_open':
> drivers/atm/firestream.c:870: warning: 'tmc0' may be used uninitialized in this function
> 
> I have confirmed that this is a false positive.
> 
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Jeff Garzik <jeff@garzik.org>
> Cc: chas williams <chas@cmf.nrl.navy.mil>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Andrew, I'm not applying patches that use that sinful
uninitialized_var() thing.

I'll apply the following instead.

commit d41a95e04ae80b77ddc186d0d97e6b439684adb8
Author: David S. Miller <davem@davemloft.net>
Date:   Fri Mar 28 16:19:26 2008 -0700

    [ATM] firestream: Fix uninitialized var warning.
    
    All code paths set tmc0 in some way, but GCC can't
    see that for some reason.  Explicitly initialize
    to zero.
    
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/atm/firestream.c b/drivers/atm/firestream.c
index 47c57a4..98099f5 100644
--- a/drivers/atm/firestream.c
+++ b/drivers/atm/firestream.c
@@ -978,6 +978,7 @@ static int fs_open(struct atm_vcc *atm_vcc)
 		/* Docs are vague about this atm_hdr field. By the way, the FS
 		 * chip makes odd errors if lower bits are set.... -- REW */
 		tc->atm_hdr =  (vpi << 20) | (vci << 4); 
+		tmc0 = 0;
 		{
 			int pcr = atm_pcr_goal (txtp);
 
