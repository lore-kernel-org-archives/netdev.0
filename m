From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Wed, 21 Apr 2010 09:21:47 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1004210915220.11040@hs20-bc2-1.build.redhat.com>
References: <20100420.181648.183008607.davem@davemloft.net>
 <Pine.LNX.4.64.1004202120180.29631@hs20-bc2-1.build.redhat.com>
 <20100420.182407.174368203.davem@davemloft.net> <20100420.190127.66303903.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5418 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754586Ab0DUNVv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 09:21:51 -0400
In-Reply-To: <20100420.190127.66303903.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 20 Apr 2010, David Miller wrote:

> 
> I looked more at your crash report.
> 
> You shouldn't even be in this code path for other reasons, namely
> skb->next should be NULL.  But it's not in your case.  skb->next would
> only be non-NULL for GSO frames, which we've established we should not
> be seeing here.
> 
> Given that skb->next is non-NULL and the fraglists of this SKB are
> corrupted (next pointer is 0x18), I think we're getting memory
> corruption from somewhere else.  This also jives with the fact that
> this is not readily reproducable.

The crash happened just a few days after I started to use the machine for 
bridging. There were no unexplained crashes before. So I suspect that the 
cause is bridging or tg3.

> The whole ->ndo_start_xmit() return value stuff is unrelated to this
> issue, we shouldn't even be in this code path.  In fact, if reverting
> that TX flags handling commit makes your crashes go away it would be a
> huge surprise.

I thought that if some weird ->ndo_start_xmit() return values appeared, 
this would lead to misunderstanding who owns the skb, using of already 
deallocated skb and mentioned memory corruption. But I can't prove it.

Mikulas
