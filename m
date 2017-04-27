From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v6 1/5] skbuff: return -EMSGSIZE in skb_to_sgvec to
 prevent overflow
Date: Thu, 27 Apr 2017 11:54:46 -0400 (EDT)
Message-ID: <20170427.115446.621009535763048376.davem@davemloft.net>
References: <20170425155215.4835-1-Jason@zx2c4.com>
	<20170425184734.26563-1-Jason@zx2c4.com>
	<CAHmME9qDmcvzF_xeaxegC2RpBOs8PziJOaKEqv6Z_X1pUFbR0w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 David.Laight@aculab.com, kernel-hardening@lists.openwall.com
To: Jason@zx2c4.com
Return-path: <kernel-hardening-return-7614-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAHmME9qDmcvzF_xeaxegC2RpBOs8PziJOaKEqv6Z_X1pUFbR0w@mail.gmail.com>
List-Id: netdev.vger.kernel.org

From: "Jason A. Donenfeld" <Jason@zx2c4.com>
Date: Thu, 27 Apr 2017 11:21:51 +0200

> Hey Dave,
> 
> David Laight and I have been discussing offlist. It occurred to both
> of us that this could just be turned into a loop because perhaps this
> is actually just tail-recursive. Upon further inspection, however, the
> way the current algorithm works, it's possible that each of the
> fraglist skbs has its own fraglist, which would make this into tree
> recursion, which is why in the first place I wanted to place that
> limit on it. If that's the case, then the patch I proposed above is
> the best way forward. However, perhaps there's the chance that
> fraglist skbs having separate fraglists are actually forbidden? Is
> this the case? Are there other parts of the API that enforce this
> contract? Is it something we could safely rely on here? If you say
> yes, I'll send a v7 that makes this into a non-recursive loop.

As Sabrina showed, it can happen.  There are no such restrictions on
the geometry of an SKB.
