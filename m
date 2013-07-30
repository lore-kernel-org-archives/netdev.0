From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: fix usage of NLM_F_EXCL or NLM_F_REPLACE
Date: Tue, 30 Jul 2013 16:44:23 -0700 (PDT)
Message-ID: <20130730.164423.1103943978365554977.davem@davemloft.net>
References: <1375093804-7534-1-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43599 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758142Ab3G3XoY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 19:44:24 -0400
In-Reply-To: <1375093804-7534-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Mon, 29 Jul 2013 12:30:04 +0200

> Currently, it is not possible to use neither NLM_F_EXCL nor
> NLM_F_REPLACE from genetlink. This is due to this checking in
> genl_family_rcv_msg:
> 
> 	if (nlh->nlmsg_flags & NLM_F_DUMP)
> 
> NLM_F_DUMP is NLM_F_MATCH|NLM_F_ROOT. Thus, if NLM_F_EXCL or
> NLM_F_REPLACE flag is set, genetlink believes that you're
> requesting a dump and it calls the .dumpit callback.
> 
> The solution that I propose is to refine this checking to
> make it stricter:
> 
> 	if ((nlh->nlmsg_flags & NLM_F_DUMP) == NLM_F_DUMP)
> 
> And given the combination NLM_F_REPLACE and NLM_F_EXCL does
> not make sense to me, it removes the ambiguity.
> 
> There was a patch that tried to fix this some time ago (0ab03c2
> netlink: test for all flags of the NLM_F_DUMP composite) but it
> tried to resolve this ambiguity in *all* existing netlink subsystems,
> not only genetlink. That patch was reverted since it broke iproute2,
> which is using NLM_F_ROOT to request the dump of the routing cache.
> 
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Yes, I remember that old attempt to fix this.

Ok, let's see what happens when we limit the scope of this change
to just genetlink users.

I honestly can't believe that NLM_F_EXCL and NLM_F_REPLACE are
completely unusable in normal rtnetlink interfaces.
