From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/2] sky2: restore multicast addresses after recovery
Date: Wed, 23 Jan 2008 19:11:51 -0800
Message-ID: <20080123191151.1423a045@deepthought>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52604 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752588AbYAXDWu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 22:22:50 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the sky2 deadman timer forces a recovery, the multicast hash
list is lost. Move the call to sky2_set_multicast to the end
of sky2_up() so all paths that bring device up will restore multicast.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
Please apply for 2.6.24

--- a/drivers/net/sky2.c	2008-01-23 16:00:34.000000000 -0800
+++ b/drivers/net/sky2.c	2008-01-23 16:04:20.000000000 -0800
@@ -1412,6 +1412,7 @@ static int sky2_up(struct net_device *de
 	imask |= portirq_msk[port];
 	sky2_write32(hw, B0_IMSK, imask);
 
+	sky2_set_multicast(dev);
 	return 0;
 
 err_out:
@@ -3533,8 +3534,6 @@ static int sky2_set_ringparam(struct net
 		err = sky2_up(dev);
 		if (err)
 			dev_close(dev);
-		else
-			sky2_set_multicast(dev);
 	}
 
 	return err;
@@ -4368,8 +4367,6 @@ static int sky2_resume(struct pci_dev *p
 				dev_close(dev);
 				goto out;
 			}
-
-			sky2_set_multicast(dev);
 		}
 	}
 
