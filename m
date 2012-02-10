From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] rtnetlink: Fix problem with buffer allocation
Date: Fri, 10 Feb 2012 13:51:51 -0500 (EST)
Message-ID: <20120210.135151.754379087490167636.davem@davemloft.net>
References: <20120210150518.4002.85507.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: gregory.v.rose@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:40550 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759844Ab2BJSv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 13:51:56 -0500
In-Reply-To: <20120210150518.4002.85507.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg Rose <gregory.v.rose@intel.com>
Date: Fri, 10 Feb 2012 07:05:18 -0800

> +/*
> + * Applications that set NLM_F_EXT have allocated
> + * a 16K or larger buffer.
> + * (Or they should have before using this flag)
> + */
> +#define NLM_F_EXT	0x800   /* Get extended interface info such as VFs */

This is not what I meant.

I meant to add a "netlink attribute" that gets passed in with GETLINK
requests.  Which is a u32 set of flag bits, one bit for each extended
feature.  So VF would get one bit.

Like "IFLA_EXT_MASK" or similar.

Then rtnl_getlink() would inspect the mask (using nla_get_32()), if
present, and make this control what extended parts of the per-link
dump are provided.
