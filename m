From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: tpacket_v3: do not trigger bug() on wrong
 header status
Date: Fri, 03 May 2013 16:12:59 -0400 (EDT)
Message-ID: <20130503.161259.257765369306912258.davem@davemloft.net>
References: <1367585820-2674-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, darkjames-ws@darkjames.pl
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48168 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934190Ab3ECUNB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 May 2013 16:13:01 -0400
In-Reply-To: <1367585820-2674-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Fri,  3 May 2013 14:57:00 +0200

> Jakub reported that it is fairly easy to trigger the BUG() macro
> from user space with TPACKET_V3's RX_RING by just giving a wrong
> header status flag. We already had a similar situation in commit
> 7f5c3e3a80e6654 (``af_packet: remove BUG statement in
> tpacket_destruct_skb'') where this was the case in the TX_RING
> side that could be triggered from user space. So really, don't use
> BUG() or BUG_ON() unless there's really no way out, and i.e.
> don't use it for consistency checking when there's user space
> involved, no excuses, especially not if you're slapping the user
> with WARN + dump_stack + BUG all at once. The two functions are
> of concern:
> 
>   prb_retire_current_block() [when block status != TP_STATUS_KERNEL]
>   prb_open_block() [when block_status != TP_STATUS_KERNEL]
> 
> Calls to prb_open_block() are guarded by ealier checks if block_status
> is really TP_STATUS_KERNEL (racy!), but the first one BUG() is easily
> triggable from user space. System behaves still stable after they are
> removed. Also remove that yoda condition entirely, since it's already
> guarded.
> 
> Reported-by: Jakub Zawadzki <darkjames-ws@darkjames.pl>
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>

Applied and queued up for -stable, thanks Daniel.
