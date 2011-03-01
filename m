From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [GIT/PATCH v3] xen network backend driver
Date: Tue, 1 Mar 2011 09:31:01 +0000
Message-ID: <1298971861.5034.1951.camel@zakaz.uk.xensource.com>
References: <1298914061.5034.996.camel@zakaz.uk.xensource.com>
	 <1298919198.2569.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	xen-devel <xen-devel@lists.xensource.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:9775 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753517Ab1CAJbG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 04:31:06 -0500
In-Reply-To: <1298919198.2569.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-02-28 at 18:53 +0000, Ben Hutchings wrote:
> 
> > --- /dev/null
> > +++ b/drivers/net/xen-netback/common.h
> [...]
> > +     /* Statistics */
> > +     int rx_gso_checksum_fixup;
> 
> This should be defined as unsigned long (ideally it would be u64, but
> that can't be updated atomically on 32-bit systems). 

Thanks, I'll address all your comments in netback shortly but first I
guess xen-netfront also needs this:

Ian.


8<-----------------------------

>From d04fc6794249e26a5e5ba5fabf1456bb0e0309d2 Mon Sep 17 00:00:00 2001
From: Ian Campbell <ian.campbell@citrix.com>
Date: Tue, 1 Mar 2011 09:29:45 +0000
Subject: [PATCH] xen: netfront: ethtool stats fields should be unsigned long

Fixup the rx_gso_checksum_fixup field added in e0ce4af920eb to be
unsigned long as suggested by Ben Hutchings in
<1298919198.2569.14.camel@bwh-desktop>

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/xen-netfront.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index a6ab973..df45323 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -122,7 +122,7 @@ struct netfront_info {
 	struct mmu_update rx_mmu[NET_RX_RING_SIZE];
 
 	/* Statistics */
-	int rx_gso_checksum_fixup;
+	unsigned long rx_gso_checksum_fixup;
 };
 
 struct netfront_rx_info {
-- 
1.5.6.5



