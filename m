From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [bisected] kernel panic 2.6.22 -> 2.6.26-rc9+
Date: Sun, 13 Jul 2008 14:55:25 -0700
Message-ID: <20080713145525.51a1ca3a.akpm@linux-foundation.org>
References: <m3d4lisk4i.fsf@maximus.localdomain>
	<20080713013107.23f060f2.akpm@linux-foundation.org>
	<m3abgmcb68.fsf@maximus.localdomain>
	<20080713112230.e86ba9ae.akpm@linux-foundation.org>
	<m3lk05jvw5.fsf@maximus.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Russell King <rmk+lkml@arm.linux.org.uk>
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:45499 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753949AbYGMV4F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2008 17:56:05 -0400
In-Reply-To: <m3lk05jvw5.fsf@maximus.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 13 Jul 2008 23:51:06 +0200 Krzysztof Halasa <khc@pm.waw.pl> wrote:

> Andrew Morton <akpm@linux-foundation.org> writes:
> 
> > --- a/include/asm-arm/bitops.h~a
> > +++ a/include/asm-arm/bitops.h
> > @@ -277,9 +277,16 @@ static inline int constant_fls(int x)
> >   * the clz instruction for much better code efficiency.
> >   */
> >  
> > -#define fls(x) \
> > +#define __fls(x) \
> >  	( __builtin_constant_p(x) ? constant_fls(x) : \
> >  	  ({ int __r; asm("clz\t%0, %1" : "=r"(__r) : "r"(x) : "cc"); 32-__r; }) )
> > +
> > +/* Implement fls() in C so that 64-bit args are suitably truncated */
> > +static inline int fls(int x)
> > +{
> > +	return __fls(x);
> > +}
> > +
> 
> Well, I like it more as it fixes all possible places instead of only
> fls64().
> 
> But... can't we just move the #define body into the inline fls(x)?
> Will there be other users of __fls(x)? It seems the
> __builtin_constant_p(x) works for inline functions.

Could.  That was a minimal&safe thing.

> The above patch fixes the kernel panic, too.

OK, thanks.
