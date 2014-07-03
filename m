From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tcp: Fix divide by zero when pushing during
 tcp-repair
Date: Wed, 02 Jul 2014 18:21:52 -0700 (PDT)
Message-ID: <20140702.182152.1004736569979242732.davem@davemloft.net>
References: <1403972797-15285-1-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, avagin@openvz.org, xemul@parallels.com
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42534 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbaGCBVx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 21:21:53 -0400
In-Reply-To: <1403972797-15285-1-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Sat, 28 Jun 2014 18:26:37 +0200

> When in repair-mode and TCP_RECV_QUEUE is set, we end up calling
> tcp_push with mss_now being 0. If data is in the send-queue and
> tcp_set_skb_tso_segs gets called, we crash because it will divide by
> mss_now:
 ...
> This can easily be reproduced with the following packetdrill-script (the
> "magic" with netem, sk_pacing and limit_output_bytes is done to prevent
> the kernel from pushing all segments, because hitting the limit without
> doing this is not so easy with packetdrill):
 ...
> This happens since ec3423257508 (tcp: fix retransmission in repair
> mode). Prior to that, the call to tcp_push was prevented by a check for
> tp->repair.
> 
> The patch fixes it, by adding the new goto-label out_nopush. When exiting
> tcp_sendmsg and a push is not required, which is the case for tp->repair,
> we go to this label.
> 
> When repairing and calling send() with TCP_RECV_QUEUE, the data is
> actually put in the receive-queue. So, no push is required because no
> data has been added to the send-queue.
> 
> Cc: Andrew Vagin <avagin@openvz.org>
> Cc: Pavel Emelyanov <xemul@parallels.com>
> Fixes: ec3423257508 (tcp: fix retransmission in repair mode)
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

Applied and queued up for -stable, thanks.
