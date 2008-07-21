From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [bug, netconsole, SLUB] BUG skbuff_head_cache: Poison overwritten
Date: Mon, 21 Jul 2008 23:57:49 +0400
Message-ID: <20080721195748.GA3191@2ka.mipt.ru>
References: <20080717214222.GA29449@elte.hu> <Pine.LNX.4.64.0807181149460.3852@sbz-30.cs.Helsinki.FI> <20080718091146.GQ6875@elte.hu> <20080721094110.GA16029@elte.hu> <84144f020807210252k68d5cf65i8c7ae3c11cecc046@mail.gmail.com> <20080721100627.GA5953@2ka.mipt.ru> <4884B7C3.9040801@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>, davem@davemloft.net
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.80.65]:52049 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753694AbYGUT76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jul 2008 15:59:58 -0400
Content-Disposition: inline
In-Reply-To: <4884B7C3.9040801@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Christoph.

On Mon, Jul 21, 2008 at 11:22:27AM -0500, Christoph Lameter (cl@linux-foundation.org) wrote:
> >Not that obvious...
> >skb->next is cleared in lots of places, in xmit network helper
> >for example, but since rest of the packet was not modified, it
> >means given skb was not freed, so it will not help.
> 
> The skb was definitely freed. 6b is written over an object when it is 
> freed. Something else retained a pointer to the skb and was confident 
> that the skb still exists.

I meant it was not tried to be freed second time, since skb->users area
(the very end of the skb) was not changed from 6b to 6a, but its
skb->next pointer (first field in the skb) was set to NULL, so after
that skb was not used at all.

It could be an interesting kmemcheck extension to catch not only
non-initialized memory, but also writes into just freed one, but not yet
returned by allocator to the next user.

-- 
	Evgeniy Polyakov
