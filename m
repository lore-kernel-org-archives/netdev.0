From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: avoid a pair of dst_hold()/dst_release() in
 ip_push_pending_frames()
Date: Mon, 24 Nov 2008 16:07:57 -0800 (PST)
Message-ID: <20081124.160757.167577430.davem@davemloft.net>
References: <492A7E85.3060502@cosmosbay.com>
	<492A8F05.3080509@cosmosbay.com>
	<492AB357.1080304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andi@firstfloor.org, netdev@vger.kernel.org, minyard@acm.org,
	christian@myri.com
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47155
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752558AbYKYAH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 19:07:57 -0500
In-Reply-To: <492AB357.1080304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 24 Nov 2008 14:59:51 +0100

> We can reduce pressure on dst entry refcount that slowdown UDP transmit
> path on SMP machines. This pressure is visible on RTP servers when
> delivering content to mediagateways, especially big ones, handling
> thousand of streams. Several cpus send UDP frames to the same
> destination, hence use the same dst entry.
> 
> This patch makes ip_push_pending_frames() steal the refcount its
> callers had to take when filling inet->cork.dst.
> 
> This doesnt avoid all refcounting, but still gives speedups on SMP,
> on UDP/RAW transmit path.
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied.
