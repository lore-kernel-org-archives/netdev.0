From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tc: fix tc actions in case of shared skb
Date: Sat, 11 Jul 2015 21:29:17 -0700 (PDT)
Message-ID: <20150711.212917.1463596559900301434.davem@davemloft.net>
References: <1436573411-5021-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jhs@mojatatu.com, daniel@iogearbox.net, jiri@resnulli.us,
	netdev@vger.kernel.org
To: ast@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60412 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750903AbbGLE3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2015 00:29:19 -0400
In-Reply-To: <1436573411-5021-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexei Starovoitov <ast@plumgrid.com>
Date: Fri, 10 Jul 2015 17:10:11 -0700

> TC actions need to check for very unlikely event skb->users != 1,
> otherwise subsequent pskb_may_pull/pskb_expand_head will crash.
> When skb_shared() just drop the packet, since in the middle of actions
> it's too late to call skb_share_check(), since classifiers/actions assume
> the same skb pointer.
> 
> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>

I think whatever creates this skb->users != 1 situation should be fixed,
they should clone the packet.

In fact, it would really help enormously if you could explain in detail
how this situation can actually arise.  Especially since I do not consider
it acceptable to drop the packet in this situation.

Thanks.
