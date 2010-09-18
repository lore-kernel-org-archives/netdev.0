From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 06/12] BKL: Remove BKL from capifs
Date: Sat, 18 Sep 2010 09:55:09 +0200
Message-ID: <201009180955.10129.arnd@arndb.de>
References: <1284659185-8942-1-git-send-email-arnd@arndb.de> <1284659185-8942-7-git-send-email-arnd@arndb.de> <20100917.163530.266095048.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:56746 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754444Ab0IRHzR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Sep 2010 03:55:17 -0400
In-Reply-To: <20100917.163530.266095048.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 18 September 2010 01:35:30 David Miller wrote:
> 
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Thu, 16 Sep 2010 19:46:19 +0200
> 
> > The BKL is only used in fill_super, which is  protected by the superblocks
> > s_umount rw_semaphore. Therefore it is safe to remove the BKL entirely.
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Cc: netdev@vger.kernel.org
> 
> I've searched Linus's tree, net-2.6, and net-next-2.6 and I cannot
> find one reference to lock_kernel() in drivers/isdn/capi/capifs.c
> in any of them.
> 
> What did you write this patch against?

As I wrote in my [PATCH 0/12], it applies on top of the pushdown
of the BKL into the get_sb operation, and I intend to submit it
to Linus with the full series.

I agree that this particular patch is a bit pointless because
all it does is to undo the change from the pushdown. I guess
that at the time when the first patch was written, the BKL
was still present in other parts of capifs.

	Arnd
