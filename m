From: Dan Carpenter <error27@gmail.com>
Subject: null dereference in ethoc_probe()
Date: Sat, 22 May 2010 17:55:47 +0200
Message-ID: <20100522155455.GE22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: thomas@wytron.com.tw
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:59071 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754742Ab0EVP4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 11:56:10 -0400
Received: by vws9 with SMTP id 9so1587953vws.19
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 08:56:09 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch 0baa080c75c: "ethoc: use system memory as buffer" introduced a
potential null dereference.

  1060  free:
  1061          if (priv->dma_alloc)
                    ^^^^^^^^^^^^^^^
	priv can be null here.

  1062                  dma_free_coherent(NULL, priv->dma_alloc, priv->membase,
  1063                          netdev->mem_start);
  1064          free_netdev(netdev);

Also I think the error handling is not as complete as it should be.  It
seems like we should call devm_iounmap() and release some of the other
resources as well.

regards,
dan carpenter

