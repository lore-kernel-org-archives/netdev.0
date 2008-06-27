From: David Howells <dhowells@redhat.com>
Subject: [PATCH] Fix missing const in vortex_probe1() in the 3c59x driver
Date: Fri, 27 Jun 2008 13:12:20 +0100
Message-ID: <20080627121220.23787.80724.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dhowells@redhat.com
To: klassert@mathematik.tu-chemnitz.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:47266 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760307AbYF0MMc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Jun 2008 08:12:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In vortex_probe1() in the 3c59x driver, print_name should be made a const
pointer to eliminate the following warning:

drivers/net/3c59x.c:1025: warning: assignment discards qualifiers from pointer target type

This is this line:

			print_name = pci_name(pdev);

Signed-off-by: David Howells <dhowells@redhat.com>
---

 drivers/net/3c59x.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 2edda8c..5972114 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -1010,7 +1010,7 @@ static int __devinit vortex_probe1(struct device *gendev,
 	static int printed_version;
 	int retval, print_info;
 	struct vortex_chip_info * const vci = &vortex_info_tbl[chip_idx];
-	char *print_name = "3c59x";
+	const char *print_name = "3c59x";
 	struct pci_dev *pdev = NULL;
 	struct eisa_device *edev = NULL;
 	DECLARE_MAC_BUF(mac);

