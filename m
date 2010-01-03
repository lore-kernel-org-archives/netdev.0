From: Dan Carpenter <error27@gmail.com>
Subject: potential overflow in de4x5.c
Date: Sun, 3 Jan 2010 12:13:56 +0200
Message-ID: <20100103101356.GA13023@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kyle McMartin <kyle@mcmartin.ca>, netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f225.google.com ([209.85.220.225]:62622 "EHLO
	mail-fx0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751994Ab0ACKOZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Jan 2010 05:14:25 -0500
Received: by fxm25 with SMTP id 25so8007135fxm.21
        for <netdev@vger.kernel.org>; Sun, 03 Jan 2010 02:14:24 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi I found this using smatch (http://repo.or.cz/w/smatch.git).

drivers/net/tulip/de4x5.c
  4772          lp->active = *p++;
  4773          if (MOTO_SROM_BUG) lp->active = 0;
  4774          lp->phy[lp->active].gep = (*p ? p : NULL); p += (2 * (*p) + 1);

lp->phy is an array of size 8.

MOTO_SROM_BUG is defined like this. 

#define MOTO_SROM_BUG    (lp->active == 8 && (get_unaligned_le32(dev->dev_addr) & 0x00ffffff) == 0x3e0008)

If lp->active == 8 then we have a buffer overflow.

regards,
dan carpenter
