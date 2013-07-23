From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: fix comment above build_skb()
Date: Tue, 23 Jul 2013 19:46:15 +0100
Message-ID: <1374605175.2072.5.camel@bwh-desktop.uk.level5networks.com>
References: <1374593943-31642-1-git-send-email-f.fainelli@gmail.com>
	 <1374594559.3449.17.camel@edumazet-glaptop>
	 <CAGVrzcZ6=591=sY6kVVrwy4BHN_0LoMZ=u2yz88QyBUvtSOydA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:22267 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933830Ab3GWSqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 14:46:19 -0400
In-Reply-To: <CAGVrzcZ6=591=sY6kVVrwy4BHN_0LoMZ=u2yz88QyBUvtSOydA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-07-23 at 19:04 +0100, Florian Fainelli wrote:
> 2013/7/23 Eric Dumazet <eric.dumazet@gmail.com>:
> > On Tue, 2013-07-23 at 16:39 +0100, Florian Fainelli wrote:
> >> build_skb() specifies that the data parameter must come from a kmalloc'd
> >> area, this is only true if frag_size equals 0, because then build_skb()
> >> will use kzsize(data) to figure out the actual data size. Update the
> >> comment to reflect that special condition.
> >>
> >> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> >> ---
> >>  net/core/skbuff.c | 3 ++-
> >>  1 file changed, 2 insertions(+), 1 deletion(-)
> >>
> >> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> >> index 20e02d2..d3174db 100644
> >> --- a/net/core/skbuff.c
> >> +++ b/net/core/skbuff.c
> >> @@ -309,7 +309,8 @@ EXPORT_SYMBOL(__alloc_skb);
> >>   * @frag_size: size of fragment, or 0 if head was kmalloced
> >>   *
> >>   * Allocate a new &sk_buff. Caller provides space holding head and
> >> - * skb_shared_info. @data must have been allocated by kmalloc()
> >> + * skb_shared_info. @data must have been allocated by kmalloc() only if
> >> + * @frag_size is 0.
> >>   * The return is the new skb buffer.
> >>   * On a failure the return is %NULL, and @data is not freed.
> >>   * Notes :
> >
> > Hmm, why not explaining the other case ? (frag_size > 0)
> 
> Sure, would something like:
> 
> "@data must have been allocated by kmalloc() if frag_size is 0,
> otherwise any data buffer (vmalloc, DMA..) is suitable"

The other case is that the buffer must have been allocated using the
page allocator directly.  It will be freed using
put_page(virt_to_head_page(data)).

Using vmalloc() to allocate the buffer would definitely be incorrect.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
