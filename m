From: Dan Carpenter <error27@gmail.com>
Subject: [patch] drop chan->wsem on error path
Date: Sun, 29 Nov 2009 18:02:55 +0200
Message-ID: <20091129160255.GN10640@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: kas@fi.muni.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.26]:37149 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751649AbZK2QCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Nov 2009 11:02:48 -0500
Received: by ey-out-2122.google.com with SMTP id 4so748412eyf.19
        for <netdev@vger.kernel.org>; Sun, 29 Nov 2009 08:02:54 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The other paths all drop chan->wsem.  This was found by a static
checker (smatch).

Signed-off-by: Dan Carpenter <error27@gmail.com>

--- orig/drivers/net/wan/cosa.c	2009-11-29 16:38:42.000000000 +0200
+++ devel/drivers/net/wan/cosa.c	2009-11-29 16:43:39.000000000 +0200
@@ -907,6 +907,7 @@ static ssize_t cosa_write(struct file *f
 			current->state = TASK_RUNNING;
 			chan->tx_status = 1;
 			spin_unlock_irqrestore(&cosa->lock, flags);
+			up(&chan->wsem);
 			return -ERESTARTSYS;
 		}
 	}
