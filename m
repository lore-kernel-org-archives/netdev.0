From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] genetlink: fix usage of NLM_F_EXCL or NLM_F_REPLACE
Date: Wed, 31 Jul 2013 19:12:57 -0700 (PDT)
Message-ID: <20130731.191257.759656829075304984.davem@davemloft.net>
References: <20130731.170348.1752477967026355787.davem@davemloft.net>
	<20130801003710.GA19777@localhost>
	<20130801020049.GA4067@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab3HACNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 22:13:09 -0400
In-Reply-To: <20130801020049.GA4067@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 1 Aug 2013 04:00:49 +0200

> On Thu, Aug 01, 2013 at 02:37:10AM +0200, Pablo Neira Ayuso wrote:
>> On Wed, Jul 31, 2013 at 05:03:48PM -0700, David Miller wrote:
> [...]
>> > Therefore I don't see how NLM_F_REPLACE and NLM_F_EXCL can be used
>> > at all, in those places, because the check is still "& NLM_F_DUMP"
>> 
>> The kind = type&3; is doing the magic there for rtnetlink. kind == 2
>> means that this is a get command, and you can only set NLM_F_DUMP
>> using the get command.
>> 
>> Since it doesn't make sense to use NLM_F_EXCL or NLM_F_REPLACE for get
>> commands, there is no room for ambiguity and rtnetlink is fine.
> 
> I had re-read what I wrote to get your point. We can fix in a
> different way by checking for: ops->flags & GENL_CMD_CAP_DUMP, which
> means we have a .dumpit callback, so only in that case genetlink
> should interpret the flags as NLM_F_DUMP.
> 
> Please, see patch attached.

Thanks for the RFC patch, I'll think about this some more and reply.
