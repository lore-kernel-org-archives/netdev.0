From: Sebastian Siewior <bigeasy@linutronix.de>
Subject: [PATCH 0/5] fixup locking on m68knommu fec
Date: Wed, 02 Apr 2008 22:58:28 +0200
Message-ID: <20080402204417.597098190@linutronix.de>
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	uclinux-dev@uclinux.org
To: Greg Ungerer <gerg@uclinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:58661 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757252AbYDBU6e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2008 16:58:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series basically fixes my locking problem. We have here:
#1 the old one which removes some undefined vars.
#2 cleans the file with lident. I had trouble reading the code...
#3 type def a function pointer so we don't have the long defines
   and move the callback after releasing the lock.
#4 This one fixes the locking I guess. My mcf5235 did not race anymore
   after that one. I saw 0a504779d while forming the patch so I guess
   we could revert that one, Greg?
#5 removes the registration of interrupt handlers & enabling interrupt
   sources that are not handled. I stepped into this after I thought that
   it is over :) Greg, Should we also remove that part where we enable
   the irq controller (I though request_irq() is doing that).

Sebastian

