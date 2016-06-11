From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net, cls: allow for deleting all filters
 for given parent
Date: Fri, 10 Jun 2016 18:15:08 -0700 (PDT)
Message-ID: <20160610.181508.1584248034068110825.davem@davemloft.net>
References: <4f60a899712d32c9c635107b4278a1b62cd18f3e.1465591897.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com,
	alexei.starovoitov@gmail.com, john.fastabend@gmail.com,
	netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33862 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbcFKBPK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 21:15:10 -0400
In-Reply-To: <4f60a899712d32c9c635107b4278a1b62cd18f3e.1465591897.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Fri, 10 Jun 2016 23:10:22 +0200

> Add a possibility where the user can just specify the parent and
> all filters under that parent are then being purged. Currently,
> for example for scripting, one needs to specify pref/prio to have
> a well-defined number for 'tc filter del' command for addressing
> the previously created instance or additionally filter handle in
> case of priorities being the same. Improve usage by allowing the
> option for tc to specify the parent and removing the whole chain
> for that given parent.
> 
> Example usage after patch, no tc changes required:
 ...
> Previously, RTM_DELTFILTER requests with invalid prio of 0 were
> rejected, so only netlink requests with RTM_NEWTFILTER and NLM_F_CREATE
> flag were allowed where the kernel would auto-generate a pref/prio.
> We can piggyback on that and use prio of 0 as a wildcard for
> requests of RTM_DELTFILTER.
> 
> For notifying tc netlink monitoring users (e.g. libnl uses this
> for caching), there are two options, that is, sending individual
> tfilter_notify() notifications for each tcf_proto, or sending a
> single one indicating wildcard removal. I tried both and there
> are pros and cons for each, eventually I decided for sending
> individual tfilter_notify(), so that user space can support this
> seamlessly and there won't be a mess of changing each and every
> application to make sure expectations from the kernel won't break
> when they don't understand single notification. Since linear chains
> don't really scale, I expect only a handful of classifiers to be
> attached at max for a given parent anyway.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
> Acked-by: Jamal Hadi Salim <jhs@mojatatu.com>

Applied.
