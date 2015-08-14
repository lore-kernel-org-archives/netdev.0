From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH RFC net 0/3] ipv6: Fix potential deadlock when creating
 pcpu rt
Date: Thu, 13 Aug 2015 17:29:09 -0700 (PDT)
Message-ID: <20150813.172909.51308259033338222.davem@davemloft.net>
References: <20150808100028.GA14897@sesse.net>
	<1439452683-964514-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgunderson@bigfoot.com,
	hannes@stressinduktion.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753233AbbHNA3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 20:29:10 -0400
In-Reply-To: <1439452683-964514-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Thu, 13 Aug 2015 00:58:00 -0700

> This patch series fixes a potential deadlock when creating a pcpu rt.
> It happens when dst_alloc() decided to run gc. Something like this:
> 
> read_lock(&table->tb6_lock);
> ip6_rt_pcpu_alloc()
> => dst_alloc()
> => ip6_dst_gc()
> => write_lock(&table->tb6_lock); /* oops */
> 
> Patch 1 and 2 are some prep works.
> Patch 3 is the fix.
> 
> Original report: https://bugzilla.kernel.org/show_bug.cgi?id=102291
> 
> Steinar, the patches can also be applied to 4.2-rc5 (I just tried).
> Can you help to test them? Thanks!

This series looks fine to me.
