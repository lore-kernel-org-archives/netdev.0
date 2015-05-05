From: Joe Perches <joe@perches.com>
Subject: Re: [RFC PATCH net-next 0/8] Convert some skb_<foo> functions to
 void
Date: Tue, 05 May 2015 16:38:48 -0700
Message-ID: <1430869128.9365.67.camel@perches.com>
References: <cover.1430769294.git.joe@perches.com>
	 <1430771550.2872.7.camel@perches.com>
	 <20150505.192003.2226565044238098170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0139.hostedemail.com ([216.40.44.139]:51004 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753742AbbEEXiv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 May 2015 19:38:51 -0400
In-Reply-To: <20150505.192003.2226565044238098170.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-05-05 at 19:20 -0400, David Miller wrote:
> From: Joe Perches <joe@perches.com> Date: Mon, 04 May 2015 13:32:30 -0700
> > On Mon, 2015-05-04 at 13:05 -0700, Joe Perches wrote:
> >> unsigned char * return values are sometimes awkward to work with.
> >> Changing the return to void * is sometimes clearer.
> >> 
> >> The only uses of the return type is to do sets like
> >>     *skb_puts(skb, 1) = char;
> >>     
> >> Adding another function specifically for that purpose allows the return
> >> type to become void.
> > 
> > Obviously, this shouldn't be applied as-is.
> > 
> > It spans too many subsystems and can be done
> > more incrementally.
> > 
> > Also, there are some missing conversions so
> > this won't compile properly (sorry 'bout that)
> 
> I have no fundamental issues with this series once you fix up those
> issues.

OK, good.

Another thing that's fairly common is an skb_put followed by
a memcpy or memset.

Adding a couple of functions for those like:

void *skb_put_memcpy(struct sk_buff *skb, void *from, size_t size);
void *skb_put_memset(struct sk_buff *skb, int c, size_t size);

would reduce code size and improve performance a little.

Are you OK with that too?
