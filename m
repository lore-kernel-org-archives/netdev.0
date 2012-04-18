From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: do not leak net_generic data on failed init
Date: Wed, 18 Apr 2012 00:05:44 -0400 (EDT)
Message-ID: <20120418.000544.1334421614802982336.davem@davemloft.net>
References: <1334587395-6033-1-git-send-email-ja@ssi.bg>
	<m1wr5d3cyv.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ja@ssi.bg, netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33529 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750730Ab2DREFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Apr 2012 00:05:53 -0400
In-Reply-To: <m1wr5d3cyv.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 17 Apr 2012 21:01:28 -0700

> Julian Anastasov <ja@ssi.bg> writes:
> 
>> 	ops_init should free the net_generic data on
>> init failure and __register_pernet_operations should not
>> call ops_free when NET_NS is not enabled.
> 
> The subject is good.
> 
> There is most definitely a leak with us not freeing the net_generic data
> on ops_init failure.  Having ops_init just take care of it seems like
> the logical place as it makes for simple analysis.
> 
> The bit about __register_pernet_operations should not call ops_free when
> NET_NS is not enabled is a bad comment.  We just need to move the
> ops_free into ops_init on failure, which is what your patch does.
> 
> Without your patch the only caller of ops_init that doesn't leak today
> is __register_pernet_operations in !CONFIG_NET_NS, precisely because
> it does that ops_free.
> 
> Now all of that said I have just read through everything and
> patch cleanly fixes a rare but real memory leak, and leaves
> the code in better state then it is today.
> 
> David please apply this patch.
> 
> Reviewed-by: "Eric W. Biederman" <ebiederm@xmission.com>

Done, thanks Eric.
