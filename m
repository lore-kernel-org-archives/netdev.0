From: Heiko Carstens <heiko.carstens@de.ibm.com>
Subject: [PATCH] prevent SSB compilation on s390 part 2
Date: Wed, 1 Aug 2007 11:34:04 +0200
Message-ID: <20070801093404.GA12124@osiris.boeblingen.de.ibm.com>
References: <20070731230932.a9459617.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:32970 "EHLO
	mtagate4.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758831AbXHAJee (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 05:34:34 -0400
Content-Disposition: inline
In-Reply-To: <20070731230932.a9459617.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Heiko Carstens <heiko.carstens@de.ibm.com>

drivers/ssb/Kconfig has already a depends on HAS_IOMEM which should
prevent SSB from being selected. But appearantly it looks like this
doesn't matter at all if it gets selected from somewhere else.
So add an explicit depends on HAS_IOMEM to the Broadcom driver to
prevent selection on s390.

Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Michael Buesch <mb@bu3sch.de>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Heiko Carstens <heiko.carstens@de.ibm.com>
---
 drivers/net/Kconfig |    1 +
 1 files changed, 1 insertion(+)

Index: linux-2.6.22/drivers/net/Kconfig
===================================================================
--- linux-2.6.22.orig/drivers/net/Kconfig
+++ linux-2.6.22/drivers/net/Kconfig
@@ -1434,6 +1434,7 @@ config APRICOT
 
 config B44
 	tristate "Broadcom 440x/47xx ethernet support"
+	depends on HAS_IOMEM
 	select SSB
 	select MII
 	help
