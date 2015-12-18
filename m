From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 4/4] ila: Add generic ILA translation
 facility
Date: Fri, 18 Dec 2015 14:18:13 -0500 (EST)
Message-ID: <20151218.141813.1894760758551190776.davem@davemloft.net>
References: <1449793173-4086221-1-git-send-email-tom@herbertland.com>
	<1449793173-4086221-5-git-send-email-tom@herbertland.com>
	<20151211111904.GB5665@breakpoint.cc>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, netdev@vger.kernel.org, kernel-team@fb.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43831 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932736AbbLRTSP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Dec 2015 14:18:15 -0500
In-Reply-To: <20151211111904.GB5665@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Fri, 11 Dec 2015 12:19:04 +0100

> So if we do ILA in init ns it & pass such skbs to other netns
> it would be preferable to use nf_register_net_hooks in a namespace
> once the first ila translation is added within that namespace.

Right, the idea is that we want to do the ILA address translation
before most other things in the stack see the headers.

In particular, we want this to happen before early socket demux.
