From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Wed, 15 Oct 2008 11:45:51 +0200
Message-ID: <48F5BBCF.3060002@trash.net>
References: <20081014175649.GA2548@ami.dom.local> <48F5049D.1000306@trash.net> <20081015082726.GA5140@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:62654 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbYJOJp5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Oct 2008 05:45:57 -0400
In-Reply-To: <20081015082726.GA5140@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Oct 14, 2008 at 10:44:13PM +0200, Patrick McHardy wrote:
> ...
>> I think we really need a peek operation since most qdiscs do have
>> some internal priorization. The question is whether all qdiscs need
>> it; I tend to think no.
> 
> Looking at qdisc_peek_len() seems to confirm a peek would be useful.
> But since this all started from the question if ->requeue() could be
> killed or simplified, I wonder if adding this peek could really help
> with this problem without too much reworking. It looks like at least
> sch_netem would still need more.

Indeed. netem is really a special case, it would be good if we could
treat it as such without requiring this kind of support from all qdiscs.
An idea would be to use a second queue for reordering that is always
tried to dequeue first. That should behave identical to what it does
now, except when the inner qdisc does reordering or rate limiting
itself.

> But if it's rather about adding something new and useful I'm OK with
> this. Anyway, I need some time to rethink this one and your previous
> description.

The main idea was to get rid of ->requeue, but it would also simplify
things slightly for HFSC, TBF and DRR (unsubmitted patch of mine).
