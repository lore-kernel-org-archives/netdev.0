From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH resent] net: ppp: Don't call bpf_prog_create() in
 ppp_lock
Date: Tue, 11 Nov 2014 15:15:38 -0500 (EST)
Message-ID: <20141111.151538.1100779026961453082.davem@davemloft.net>
References: <1415616621-3481-1-git-send-email-tiwai@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org,
	linux-ppp@vger.kernel.org, stefan.seyfried@googlemail.com
To: tiwai@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbaKKUPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 15:15:44 -0500
In-Reply-To: <1415616621-3481-1-git-send-email-tiwai@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Takashi Iwai <tiwai@suse.de>
Date: Mon, 10 Nov 2014 11:50:21 +0100

> In ppp_ioctl(), bpf_prog_create() is called inside ppp_lock, which
> eventually calls vmalloc() and hits BUG_ON() in vmalloc.c.  This patch
> works around the problem by moving the allocation outside the lock.
> 
> The bug was revealed by the recent change in net/core/filter.c, as it
> allocates via vmalloc() instead of kmalloc() now.
> 
> Reported-and-tested-by: Stefan Seyfried <stefan.seyfried@googlemail.com>
> Signed-off-by: Takashi Iwai <tiwai@suse.de>

Applied and queued up for -stable, thanks.
