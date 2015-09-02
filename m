From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 3/3] ipv6: Fix dst_entry refcnt bugs in ip6_tunnel
Date: Wed, 02 Sep 2015 16:14:34 -0700 (PDT)
Message-ID: <20150902.161434.716803405458928425.davem@davemloft.net>
References: <20150902215203.GB78846@kafai-mba.local>
	<1441234137.8932.209.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150902231031.GC78846@kafai-mba.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39973 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753182AbbIBXOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 19:14:35 -0400
In-Reply-To: <20150902231031.GC78846@kafai-mba.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 2 Sep 2015 16:10:31 -0700

> On Wed, Sep 02, 2015 at 03:48:57PM -0700, Eric Dumazet wrote:
>> dst_free() is called after RCU grace period, in the case you are
>> interested in.
>>
>> Look at dst_rcu_free() and rt_free()
> Yes for IPv4 FIB
> 
> Not for IPv6 FIB. F.e. rt6_release()
> The IPv6 FIB is protected by rwlock now.

The FIB tree can use whatever locking scheme it wants, but the
actual route objects need to be released via RCU to fix the
problems you are seeing.

Converting the entire ipv6 FIB tree handling to RCU is not a
prerequisite for this.
