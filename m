From: David VomLehn <dvomlehn@cisco.com>
Subject: Re: [Patch 1/1][RFC] NETDEV: Find network bugs by validating the
	sk_buff state
Date: Thu, 30 Apr 2009 11:23:39 -0700
Message-ID: <20090430182339.GA16896@cuplxvomd02.corp.sa.net>
References: <20090430163200.GC15170@cuplxvomd02.corp.sa.net> <20090430.094614.13889468.davem@davemloft.net> <20090430175913.GA12737@cuplxvomd02.corp.sa.net> <20090430.110549.62531937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:47027 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762459AbZD3SYt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 14:24:49 -0400
Content-Disposition: inline
In-Reply-To: <20090430.110549.62531937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 30, 2009 at 11:05:49AM -0700, David Miller wrote:
> From: David VomLehn <dvomlehn@cisco.com>
> Date: Thu, 30 Apr 2009 10:59:13 -0700
> 
> > Your description is general enough that I may misunderstand your idea,
> > but it sounds like, if debugging was on, you'd be recording every call to
> > alloc_skb and kfree_skb in your table. This would use a lot of memory.
> > You can't simply have a circular list, because an sk_buff might be allocated
> > for a very long time before being used and you would overwrite its entry.
> > This would reduce the reliability of the information, which is the last thing
> > you want in a debugging tool. So, I'm considering approaches without this
> > drawback.
> 
> A developer trying to diagnose something is explicitly turning
> this on then trying to reproduce.  Since it's only on when wanted
> we can either 1) make it really large or 2) allow the sysctl itself
> to specify the table size.

There are two risks:
1.	You allocate so much memory that you perturb the behavior of the
	system and the bug you are looking for doesn't occur.
2.	You lose the data you are looking for, which is almost guaranteed to
	be something that is difficult to reproduce.

An approach that can avoid these from the start seems better. Right now, I
think such approaches exist.

David VomLehn
