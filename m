From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 1/2] net: don't use in_atomic() in gfp_any()
Date: Wed, 11 Feb 2009 13:48:42 -0800
Message-ID: <20090211134842.7fa73b6d.akpm@linux-foundation.org>
References: <200902112127.n1BLRJeJ031575@imap1.linux-foundation.org>
	<200902120638.BFG12928.FFMOHJOVtOQLFS@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:48838 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755711AbZBKVtF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 16:49:05 -0500
In-Reply-To: <200902120638.BFG12928.FFMOHJOVtOQLFS@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Feb 2009 06:38:55 +0900
Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> Andrew Morton wrote:
> > Solve both these problems by switching to in_interrupt().  Now, if someone
> > runs a gfp_any() allocation from inside spinlock we will get the warning
> > if CONFIG_PREEMPT=y.
> 
> >  static inline gfp_t gfp_any(void)
> >  {
> > -	return in_atomic() ? GFP_ATOMIC : GFP_KERNEL;
> > +	return in_softirq() ? GFP_ATOMIC : GFP_KERNEL;
> >  }
> sed -i -e 's/in_softirq/in_interrupt/' ?

heh, good question.

I did all my testing with in_softirq() - the changelog didn't catch up.



Is gfp_any() supposed to be usable from hardirq context?

If so, we should use in_interrupt().

If not, we should use in_softirq(), and we'll then get might_sleep()
warnings if anyone uses gfp_any() from hard irq context.




