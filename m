From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: RE: [NET]: Fix ___pskb_trim when entire frag_list needs dropping
Date: Wed, 02 Aug 2006 17:01:17 +0200
Message-ID: <BAY103-F18A6256BE13955FA46DA0DB2520@phx.gbl>
References: <20060729114525.GA10549@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed
Cc: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc3-s8.bay0.hotmail.com ([65.54.246.208]:20194 "EHLO
	bay0-omc3-s8.bay0.hotmail.com") by vger.kernel.org with ESMTP
	id S1751162AbWHBPBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 11:01:19 -0400
In-Reply-To: <20060729114525.GA10549@gondor.apana.org.au>
To: herbert@gondor.apana.org.au
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:

>On Thu, Jul 13, 2006 at 07:03:41PM +1000, herbert wrote:
> >
> > This needs to go into stable as well.  In fact, there is another 
>unrelated
> > bug with exactly the same symptoms which was inadvertently fixed by the
> > GSO patches.  So I'll send a simpler fix for that to stable.
> >
> > [NET]: Update frag_list in pskb_trim
>
>Marco told me that he was still seeing the same problem.  Turns out that
>my patch missed one important case.  I hope this is really the last time
>I have to look at this bug :)
>
>[NET]: Fix ___pskb_trim when entire frag_list needs dropping
>
>When the trim point is within the head and there is no paged data,
>___pskb_trim fails to drop the first element in the frag_list.
>This patch fixes this by moving the len <= offset case out of the
>page data loop.
>
>This patch also adds a missing kfree_skb on the frag that we just
>cloned.

The problem is fixed now. I have applied this
patch to 2.6.18-rc2
Many thanks Herbert for all the time spent
to debug this problem.


