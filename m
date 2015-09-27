From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] ila: Use NF_INET_PRE_ROUTING nfhook
Date: Sat, 26 Sep 2015 23:15:54 -0700 (PDT)
Message-ID: <20150926.231554.1860934088223264189.davem@davemloft.net>
References: <1443112224-574543-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernel-team@fb.com
To: tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41199 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751201AbbI0GP5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 02:15:57 -0400
In-Reply-To: <1443112224-574543-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <tom@herbertland.com>
Date: Thu, 24 Sep 2015 09:30:20 -0700

> This patch set addresses the issue for ILA by adding a fast locator
> lookup that occurs before early demux. This is done by using a hook
> at NF_INET_PRE_ROUTING. For the backend we implement an rhashtable
> that contains identifier to locator to mappings. The table also
> allows more specific matches that include original locator and
> interface.

I really don't think we should use netfilter hooks to perform
operations setup outside of netfilter's normal configuration
mechanisms.

It is not a set of arbitray hooks to take advantage of in another
subsystem or facility.

If ILA were instead configured inside of netfilter's normal mechanisms
then there would be full transparency about whether ILA
transformations are performed before or after the user's other
netfilter rules.  And the user would have full control over this.
As implemented here, they don't.

So sorry, I'm not too keen on this and I bet if netfilter developers
reviewed this patch series they'd have similar objections.
