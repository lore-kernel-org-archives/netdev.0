From: Dan Carpenter <error27@gmail.com>
Subject: off by one in sdla_close()
Date: Sun, 3 Jan 2010 12:04:05 +0200
Message-ID: <20100103100405.GC13263@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Mike McLagan <mike.mclagan@linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:59257 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751096Ab0ACKEX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2010 05:04:23 -0500
Received: by fxm25 with SMTP id 25so8004115fxm.21
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2010 02:04:21 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

drivers/net/wan/sdla.c
   955                  for(i=0;i<CONFIG_DLCI_MAX;i++)
   956                          if (flp->dlci[i] > 0)
   957                                  sdla_cmd(dev, SDLA_DEACTIVATE_DLCI, 0, 0, dlcis, len, NULL, NULL);
   958                  sdla_cmd(dev, SDLA_DELETE_DLCI, 0, 0, &flp->dlci[i], sizeof(flp->dlci[i]), NULL, NULL);
 
At the end of the for loop i == CONFIG_DLCI_MAX which is too high.

regards,
dan carpenter
