From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [IPV4] route: Dynamic hash table sizing.
Date: Tue, 15 Aug 2006 01:35:41 -0700 (PDT)
Message-ID: <20060815.013541.13768684.davem@davemloft.net>
References: <20060809.005337.104642177.davem@davemloft.net>
	<200608091209.29231.dada1@cosmosbay.com>
	<20060809.041452.102575985.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:34013
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965301AbWHOIfj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Aug 2006 04:35:39 -0400
To: dada1@cosmosbay.com
In-Reply-To: <20060809.041452.102575985.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 09 Aug 2006 04:14:52 -0700 (PDT)

> From: Eric Dumazet <dada1@cosmosbay.com>
> Date: Wed, 9 Aug 2006 12:09:28 +0200
> 
> > On Wednesday 09 August 2006 09:53, David Miller wrote:
> > 
> > > +	if (atomic_read(&ipv4_dst_ops.entries) >= (hmask + 1) &&
> > > +	    (hmask + 1) < ip_rt_hashsz_limit)
> > > +		schedule_work(&rtcache_work);
> > > +	return 0;
> > >  }
> > >
> > 
> > I wonder if you should not replicate this test (against (hmask + 1) < 
> > ip_rt_hashsz_limit) in rtcache_resize() itself, because we might end calling 
> > rthash_new_size() while (hmask +1 ) = ip_rt_hashsz_limit
> 
> That's a good point, let me think about that.

Ok, I don't think this is an issue.

schedule_work() will only cause one invocation of rthash_new_size()
even if you call schedule_work() several times before the actual
workqueue invocation of rtcache_new_size().
