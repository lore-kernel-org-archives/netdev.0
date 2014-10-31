From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net 0/2] net: systemport: TX dma fixes
Date: Fri, 31 Oct 2014 15:51:33 -0700
Message-ID: <1414795895-31612-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:45006 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753636AbaJaWwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2014 18:52:31 -0400
Received: by mail-pa0-f54.google.com with SMTP id rd3so8645682pab.27
        for <netdev@vger.kernel.org>; Fri, 31 Oct 2014 15:52:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series contains two fixes for our transmit path, first one
is a pretty nasty one since we were not allocating a large enough
dma coherent pool for our transmit descriptors, which would work most of the
time, since allocations are contiguous and we could have.

Second patch fixes a less frequent, though highly likley crash when using
CMA allocations.

I just missed your pull request to Linus, though I assume there will be
another one?

Thanks!

Florian Fainelli (2):
  net: systemport: fix DMA allocation/freeing sizes
  net: systemport: do not crash freeing an unitialized TX ring

 drivers/net/ethernet/broadcom/bcmsysport.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

-- 
1.9.1
