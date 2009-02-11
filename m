From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Subject: Re: [patch 1/2] net: don't use in_atomic() in gfp_any()
Date: Thu, 12 Feb 2009 06:38:55 +0900
Message-ID: <200902120638.BFG12928.FFMOHJOVtOQLFS@I-love.SAKURA.ne.jp>
References: <200902112127.n1BLRJeJ031575@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:52899 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751013AbZBKWHQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Feb 2009 17:07:16 -0500
In-Reply-To: <200902112127.n1BLRJeJ031575@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton wrote:
> Solve both these problems by switching to in_interrupt().  Now, if someone
> runs a gfp_any() allocation from inside spinlock we will get the warning
> if CONFIG_PREEMPT=y.

>  static inline gfp_t gfp_any(void)
>  {
> -	return in_atomic() ? GFP_ATOMIC : GFP_KERNEL;
> +	return in_softirq() ? GFP_ATOMIC : GFP_KERNEL;
>  }
sed -i -e 's/in_softirq/in_interrupt/' ?
