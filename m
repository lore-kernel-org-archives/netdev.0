From: David Miller <davem@davemloft.net>
Subject: Re: linkwatch bustage in git-net
Date: Tue, 08 May 2007 23:22:11 -0700 (PDT)
Message-ID: <20070508.232211.88475000.davem@davemloft.net>
References: <20070509053154.GA850@gondor.apana.org.au>
	<20070509054558.GA1184@gondor.apana.org.au>
	<20070508231143.fcae61c7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44449
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S933482AbXEIGWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 02:22:11 -0400
In-Reply-To: <20070508231143.fcae61c7.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 8 May 2007 23:11:43 -0700

> On Wed, 9 May 2007 15:45:58 +1000 Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > On Wed, May 09, 2007 at 03:31:55PM +1000, Herbert Xu wrote:
> > > 
> > > Hmm, I don't see it here (probably because we use different NICs).
> > > But does this help?
> > 
> > Thinking about it again I don't think it will help you because if your
> > carrier started out as off then it would've been considered an urgent
> > event anyway.
> > 
> > So what NIC are you using? And where abouts in the boot process is it
> > hanging? For exmaple, is it hanging when obtaining a DHCP address?
> > 
> > In any case, this patch can't hurt.  So here's one with a changelog:
> > 
> > [NET] link_watch: Eliminate potential delay on wrap-around
> 
> hm, that fixed it.  Do we know why? ;)

I wonder if, because of how we initialize jiffies on bootup to find
wraparound bugs, urgent_event is always true.

If it is always true, linkwatch_nextevent will never get updated.
Herbert's patch indirectly corrects that.

In the mean time I'll stick Herbert's patch into net-2.6
