From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net 0/3] ipv6: Fix a potential deadlock when
 creating pcpu rt
Date: Mon, 17 Aug 2015 14:28:27 -0700 (PDT)
Message-ID: <20150817.142827.2220495058071113737.davem@davemloft.net>
References: <1439575554-3823839-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sgunderson@bigfoot.com,
	hannes@stressinduktion.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:36409 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751858AbbHQV22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 17:28:28 -0400
In-Reply-To: <1439575554-3823839-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 14 Aug 2015 11:05:51 -0700

> v1 -> v2:
> A minor change in the commit message of patch 2.
> 
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

Series applied.
