From: David Miller <davem@davemloft.net>
Subject: Re: ip6_rt_gc_elasticity and ip6_rt_gc_min_interval race in
 rt6_alloc_cow() ?
Date: Fri, 30 Nov 2012 13:50:14 -0500 (EST)
Message-ID: <20121130.135014.1380924721756973206.davem@davemloft.net>
References: <20121130184336.GB7113@midget.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mkubecek@suse.cz
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161104Ab2K3SuQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Nov 2012 13:50:16 -0500
In-Reply-To: <20121130184336.GB7113@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Fri, 30 Nov 2012 19:43:36 +0100

> I believe there is a race condition in the setting of
> ip6_rt_gc_elasticity and ip6_rt_gc_min_interval. I have not seen
> happen, though:
> 
> 1) a setting made by the user via sysctl while ip6_dst_gc() is
>    running will get lost
> 
> 2) another instance of rt6_alloc_cow() may save the temporary
>    values in the saved_* variables, making those permanent.
> 
> Am I overlooking some synchronization or should I send a
> patch to fix this?

The ipv4 routing cache had the same issue, I really and sincerely
doubt this race matters in practice.
