From: Andi Kleen <andi@firstfloor.org>
Subject: Re: RFC: Nagle latency tuning
Date: Mon, 22 Sep 2008 22:30:42 +0200
Message-ID: <20080922203042.GY25711@one.firstfloor.org>
References: <48C6C300.4050102@redhat.com> <20080909.125934.150042096.davem@davemloft.net> <20080922.034933.119934091.davem@davemloft.net> <20080922.040912.193700258.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: csnook@redhat.com, andi@firstfloor.org, rick.jones2@hp.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:60784 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbYIVUZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 16:25:56 -0400
Content-Disposition: inline
In-Reply-To: <20080922.040912.193700258.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 22, 2008 at 04:09:12AM -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 22 Sep 2008 03:49:33 -0700 (PDT)
> 
> > I'll try to figure out why Andi's patch doesn't behave as expected.
> 
> Andi's patch uses proc_dointvec_jiffies, which is for sysctl values
> stored as seconds, whereas these things are used to record values with
> smaller granulatiry, are stored in jiffies, and that's why we get zero
> on read and writes have crazy effects.

Oops. Assume me with brown paper bag etc.etc.

It was a typo for proc_dointvec_ms_jiffies


> 
> Also, as Andi stated, this is not the way to deal with this problem.
> 
> So we have a broken patch, which even if implemented properly isn't the
> way forward, so I consider this discussion dead in the water until we
> have some test cases.

The patch is easy to fix with a s/_jiffies/_ms_jiffies/g

Also it was more intended for him to play around and get some data
points. I guess for that it's still useful.

Also while for that it's probably not the right solution, but 
I could imagine in some other situations where it might be useful
to tune these values. After all they are not written down in stone.
I wonder if it would even make sense to consider hr timers for TCP
now.

=Andi
-- 
ak@linux.intel.com
