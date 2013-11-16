From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: unify registration functions
Date: Fri, 15 Nov 2013 20:52:05 -0500 (EST)
Message-ID: <20131115.205205.1547026485764326432.davem@davemloft.net>
References: <1384521548-13241-1-git-send-email-johannes@sipsolutions.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johannes.berg@intel.com
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60997 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192Ab3KPBwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Nov 2013 20:52:07 -0500
In-Reply-To: <1384521548-13241-1-git-send-email-johannes@sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Fri, 15 Nov 2013 14:19:08 +0100

> From: Johannes Berg <johannes.berg@intel.com>
> 
> Now that the ops assignment is just two variables rather than a
> long list iteration etc., there's no reason to separately export
> __genl_register_family() and __genl_register_family_with_ops().
> 
> Unify the two functions into __genl_register_family() and make
> genl_register_family_with_ops() call it after assigning the ops.
> 
> Signed-off-by: Johannes Berg <johannes.berg@intel.com>

Looks great, applied.

As a future simplification perhaps we can even elide the array length
argument.  Most pass ARRAY_SIZE(foo) but there is at least one case
(DLM) which passes a constant, which is error prone.

#define genl_register_family_with_ops(family, ops)
	__genl_register_family_with_ops(family, ops, ARRAY_SIZE(ops))

something like that.
