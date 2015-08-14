From: Martin KaFai Lau <kafai@fb.com>
Subject: Re: [PATCH RFC net 0/3] ipv6: Fix potential deadlock when creating
 pcpu rt
Date: Fri, 14 Aug 2015 10:18:13 -0700
Message-ID: <20150814171813.GB359689@devbig242.prn2.facebook.com>
References: <20150808100028.GA14897@sesse.net>
 <1439452683-964514-1-git-send-email-kafai@fb.com>
 <20150813.172909.51308259033338222.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <sgunderson@bigfoot.com>,
	<hannes@stressinduktion.org>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:45408 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755209AbbHNRU7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 13:20:59 -0400
Content-Disposition: inline
In-Reply-To: <20150813.172909.51308259033338222.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 13, 2015 at 05:29:09PM -0700, David Miller wrote:
> From: Martin KaFai Lau <kafai@fb.com>
> Date: Thu, 13 Aug 2015 00:58:00 -0700
> 
> > This patch series fixes a potential deadlock when creating a pcpu rt.
> > It happens when dst_alloc() decided to run gc. Something like this:
> > 
> > read_lock(&table->tb6_lock);
> > ip6_rt_pcpu_alloc()
> > => dst_alloc()
> > => ip6_dst_gc()
> > => write_lock(&table->tb6_lock); /* oops */
> > 
> > Patch 1 and 2 are some prep works.
> > Patch 3 is the fix.
> > 
> > Original report: https://bugzilla.kernel.org/show_bug.cgi?id=102291
> > 
> > Steinar, the patches can also be applied to 4.2-rc5 (I just tried).
> > Can you help to test them? Thanks!
> 
> This series looks fine to me.
Thanks. I will repost it with a minor change in one of the commit messages.
