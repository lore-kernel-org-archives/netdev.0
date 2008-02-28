From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: printk_ratelimit and net_ratelimit conflict and tunable
 behavior
Date: Thu, 28 Feb 2008 10:39:55 -0800
Message-ID: <20080228103955.570ade3e.akpm@linux-foundation.org>
References: <200802252036.m1PKaeMY012587@ftw.mot.com>
	<20080225154521.e119cbb6.akpm@linux-foundation.org>
	<7BFDACCD6948EF4D8FE8F4888A91596A01637208@tx14exm60.ds.mot.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <joe@perches.com>,
	<linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>
To: "Hawkes Steve-FSH016" <Steve.Hawkes@motorola.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([207.189.120.13]:50252 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751657AbYB1Skg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Feb 2008 13:40:36 -0500
In-Reply-To: <7BFDACCD6948EF4D8FE8F4888A91596A01637208@tx14exm60.ds.mot.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 28 Feb 2008 10:19:02 -0600 "Hawkes Steve-FSH016" <Steve.Hawkes@motorola.com> wrote:

> Andrew Morton wrote:
> 
> > This patch causes a large and nasty reject.
> > Probably because you patched 2.6.24.  We're developing 2.6.25 now, and
> > the difference between the two is very large inded.  Please raise
> patches
> > against Linus's latest tree?
> 
> Will do. I'm learning the process. I assume Linus's latest tree is the
> one
> listed as the latest prepatch for the stable Linux kernel tree.

No, the stable tree is 2.6.24.  You'll want
ftp://ftp.kernel.org/pub/linux/kernel/v2.6/snapshots/

> > >  int net_ratelimit(void)
> > >  {
> > > -	return __printk_ratelimit(net_msg_cost, net_msg_burst);
> > > +	static struct printk_ratelimit_state limit_state = {
> > > +		.toks          = 10 * 5 * HZ,
> > > +		.last_jiffies  = 0,
> > > +		.missed        = 0,
> > > +		.limit_jiffies = 5 * HZ,
> > > +		.limit_burst   = 10,
> > > +		.facility      = "net"
> > > +	};
> > > +
> > > +	return __printk_ratelimit(net_msg_cost, net_msg_burst,
> &limit_state);
> > 
> > I don't get it.  There's one instance of limit_state, kernel-wide, and
> > __printk_ratelimit() modifies it.  What prevents one CPU's activities
> from
> > interfering with a second CPU's activities?
> 
> The state is protected by the spinlock in __printk_ratelimit, like it is
> in
> the current kernel. Am I missing something?

ah, OK.

I've occasionally wondered if ratelimiting should be per-callsite rather
than kernel-wide, but I'm not aware of the present setup causing anyone any
problems.

