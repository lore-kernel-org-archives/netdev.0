From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] ifb: support more features
Date: Mon, 09 May 2016 10:41:52 -0700
Message-ID: <1462815712.23934.36.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1462578076.13075.63.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462583999.13075.67.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462686072.23934.4.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462723712.23934.18.camel@edumazet-glaptop3.roam.corp.google.com>
	 <1462728942.23934.23.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CAKgT0UffTCeUn5jqFYNqtE6g25sdcAvT6hLNG1F=0BKRWd-xWA@mail.gmail.com>
	 <1462815597.23934.35.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Alexander Duyck <aduyck@mirantis.com>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <tom@herbertland.com>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33552 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751059AbcEIRly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 May 2016 13:41:54 -0400
Received: by mail-pa0-f49.google.com with SMTP id xk12so75371763pac.0
        for <netdev@vger.kernel.org>; Mon, 09 May 2016 10:41:54 -0700 (PDT)
In-Reply-To: <1462815597.23934.35.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-05-09 at 10:39 -0700, Eric Dumazet wrote:
> On Mon, 2016-05-09 at 10:22 -0700, Alexander Duyck wrote:
> 
> > One thought that just occurred to me based on this would be to
> > configure inner headers on the way up, and to configure the outer
> > headers on the way down.  Then that way we could go through and be
> > guaranteed that the inner headers represent the inner most set of
> > header offsets, and the outer ones represent the outer-most set
> > regardless of the total number of headers present and there would be
> > no need to call into the reset_headers function since all the headers
> > would already be set.
> > 
> > I was also looking at possibly dropping the inner transport offset as
> > from what I can tell it and the csum_offset should always be the same
> > value since csum_offset will always point to the inner transport
> > header when any kind of offload is enabled which is the criteria for
> > skb->encapsulation being set anyway.
> 
> Ideally nothing should be changed in the source skb while doing
> gso_segment() calls.
> 
> As we did in gro_complete() when adding nhoff argument, we probably
> could pass the current offset and not touch skb->data and various header
> offsets.

Ugly things like skb_gso_error_unwind() would then disappear.

What a mess it is.
