From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: sctp: keep owned chunk in
 destructor_arg instead of skb->cb
Date: Fri, 21 Nov 2014 14:51:53 -0500 (EST)
Message-ID: <20141121.145153.1551371249438323651.davem@davemloft.net>
References: <1416444888-12778-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38106 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863AbaKUTvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2014 14:51:55 -0500
In-Reply-To: <1416444888-12778-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Thu, 20 Nov 2014 01:54:48 +0100

> It's just silly to hold the skb destructor argument around inside
> skb->cb[] as we currently do in SCTP.
> 
> Nowadays, we're sort of cheating on data accounting in the sense
> that due to commit 4c3a5bdae293 ("sctp: Don't charge for data in
> sndbuf again when transmitting packet"), we orphan the skb already
> in the SCTP output path, i.e. giving back charged data memory, and
> use a different destructor only to make sure the sk doesn't vanish
> on skb destruction time. Thus, cb[] is still valid here as we
> operate within the SCTP layer. (It's generally actually a big
> candidate for future rework, imho.)
> 
> However, storing the destructor in the cb[] can easily cause issues
> should an non sctp_packet_set_owner_w()'ed skb ever escape the SCTP
> layer, since cb[] may get overwritten by lower layers and thus can
> corrupt the chunk pointer. There are no such issues at present,
> but lets keep the chunk in destructor_arg, as this is the actual
> purpose for it.
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  v1->v2:
>   - Only reworded commit message to make it more clear

Applied, thanks.
