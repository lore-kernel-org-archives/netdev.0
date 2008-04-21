From: Grant Grundler <grundler@parisc-linux.org>
Subject: [PATCH] 2.6.25 typhoon_resume - remove call to start_queue
Date: Sun, 20 Apr 2008 22:44:15 -0600
Message-ID: <20080421044415.GB15080@colo.lackof.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com, David Dillow <dave@thedillows.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from colo.lackof.org ([198.49.126.79]:36564 "EHLO colo.lackof.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751061AbYDUEo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 00:44:27 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jeff,

While trying to fix http://bugzilla.kernel.org/show_bug.cgi?id=8952
I looked at a few other drivers to figure out what drivers _should_
be doing for suspend/resume. I noticed typhoon driver is likely doing
more than it needs to.  Patch below is untested since I don't have the HW.

Suspend/resume code across NIC drivers is fairly inconsistent.
And I couldn't find any documentation on what the canonical sequence
NICs need to do for suspend or resume.  Is there any?

Barring contrary advice, I'm going model the tulip suspend/resume
fixes after tg3.c since a number of "modern" (< 5 years old) laptops
have that and I'm silly enough to assume it works.

thanks,
grant

---
Comments/code in netif_device_attach() suggest it is restarting the queue.
Thus, typhoon_resume() doesn't need to call start_queue().

Signed-off-by: Grant Grundler <grundler@parisc-linux.org>

diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 333961b..c0dd25b 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -2183,7 +2183,6 @@ typhoon_resume(struct pci_dev *pdev)
 	}
 
 	netif_device_attach(dev);
-	netif_start_queue(dev);
 	return 0;
 
 reset:
