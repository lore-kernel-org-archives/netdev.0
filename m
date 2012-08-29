From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] netpoll: revert 6bdb7fe3104 and fix be_poll() instead
Date: Wed, 29 Aug 2012 15:06:05 -0400 (EDT)
Message-ID: <20120829.150605.81786816498426745.davem@davemloft.net>
References: <1345880471-29535-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, s.munaut@whatever-company.com,
	akpm@linux-foundation.org, sathya.perla@emulex.com,
	subbu.seetharaman@emulex.com, ajit.khaparde@emulex.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52634 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754549Ab2H2TGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2012 15:06:09 -0400
In-Reply-To: <1345880471-29535-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sat, 25 Aug 2012 15:41:11 +0800

> Against -net.
> 
> In the patch "netpoll: re-enable irq in poll_napi()", I tried to
> fix the following warning:
 ...
> by reenabling IRQ before calling ->poll, but it seems more
> problems are introduced after that patch:
> 
> http://ozlabs.org/~akpm/stuff/IMG_20120824_122054.jpg
> http://marc.info/?l=linux-netdev&m=134563282530588&w=2
> 
> So it is safe to fix be2net driver code directly.
> 
> This patch reverts the offending commit and fixes be_poll() by
> avoid disabling BH there, this is okay because be_poll()
> can be called either by poll_napi() which already disables
> IRQ, or by net_rx_action() which already disables BH.
> 
> Reported-by: Andrew Morton <akpm@linux-foundation.org>
> Reported-by: Sylvain Munaut <s.munaut@whatever-company.com>
> Cc: Sylvain Munaut <s.munaut@whatever-company.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: David Miller <davem@davemloft.net>
> Cc: Sathya Perla <sathya.perla@emulex.com>
> Cc: Subbu Seetharaman <subbu.seetharaman@emulex.com>
> Cc: Ajit Khaparde <ajit.khaparde@emulex.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied, thanks.
