From: Ben Hutchings <ben@decadent.org.uk>
Subject: [19/75] rt2x00: rt2x00pci_regbusy_read() - only print register
 access failure once
Date: Mon, 22 Apr 2013 15:25:59 +0100
Message-ID: <lsq.1366640759.619028946@decadent.org.uk>
References: <lsq.1366640759.151900666@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: akpm@linux-foundation.org,
	"Gertjan van Wingerde" <gwingerde@gmail.com>,
	"Tim Gardner" <tim.gardner@canonical.com>,
	linux-wireless@vger.kernel.org,
	"Helmut Schaa" <helmut.schaa@googlemail.com>,
	"Ivo van Doorn" <IvDoorn@gmail.com>, netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	users@rt2x00.serialmonkey.com
To: linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:51696 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755120Ab3DVOa1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Apr 2013 10:30:27 -0400
Content-Disposition: inline
In-Reply-To: <lsq.1366640759.151900666@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

3.2.44-rc1 review patch.  If anyone has any objections, please let me know.

------------------

From: Tim Gardner <tim.gardner@canonical.com>

commit 83589b30f1e1dc9898986293c9336b8ce1705dec upstream.

BugLink: http://bugs.launchpad.net/bugs/1128840

It appears that when this register read fails it never recovers, so
I think there is no need to repeat the same error message ad infinitum.

Cc: Ivo van Doorn <IvDoorn@gmail.com>
Cc: Gertjan van Wingerde <gwingerde@gmail.com>
Cc: Helmut Schaa <helmut.schaa@googlemail.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: linux-wireless@vger.kernel.org
Cc: users@rt2x00.serialmonkey.com
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
---
 drivers/net/wireless/rt2x00/rt2x00pci.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/net/wireless/rt2x00/rt2x00pci.c
+++ b/drivers/net/wireless/rt2x00/rt2x00pci.c
@@ -52,8 +52,8 @@ int rt2x00pci_regbusy_read(struct rt2x00
 		udelay(REGISTER_BUSY_DELAY);
 	}
 
-	ERROR(rt2x00dev, "Indirect register access failed: "
-	      "offset=0x%.08x, value=0x%.08x\n", offset, *reg);
+	printk_once(KERN_ERR "%s() Indirect register access failed: "
+	      "offset=0x%.08x, value=0x%.08x\n", __func__, offset, *reg);
 	*reg = ~0;
 
 	return 0;
