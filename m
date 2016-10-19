From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix signedness of tmp_prefered_lft underflow
 check
Date: Wed, 19 Oct 2016 14:58:16 -0400 (EDT)
Message-ID: <20161019.145816.259194714319437266.davem@davemloft.net>
References: <20161018150154.4tpivtvxygp7kjpd@dwarf.suse.cz>
        <20161018.142525.1262217492229127435.davem@davemloft.net>
        <20161019131636.zhusbqh63qlbq5vy@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: julia.lawall@lip6.fr, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
        yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
        kbuild-all@01.org
To: jbohac@suse.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59526 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932933AbcJSS6U (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 14:58:20 -0400
In-Reply-To: <20161019131636.zhusbqh63qlbq5vy@dwarf.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Bohac <jbohac@suse.cz>
Date: Wed, 19 Oct 2016 15:16:36 +0200

> The purpose was to guard against the user updating the
> temp_prefered_lft sysctl after this:
> 
>         max_desync_factor = min_t(__u32,
>                                   idev->cnf.max_desync_factor,
>                                   idev->cnf.temp_prefered_lft - regen_advance);
> 
> but before this:
> 
> 	tmp_prefered_lft = idev->cnf.temp_prefered_lft + age -
> 			    idev->desync_factor;

That's a different problem.

Read the sysctl values of interest into local variables using
READ_ONCE() before the calculations, that way the situation your
describe is impossible.
