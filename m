From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 17:27:45 +0200
Message-ID: <465D97F1.9090600@trash.net>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain> <1180536987.4109.19.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41980 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750890AbXE3P1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 11:27:48 -0400
In-Reply-To: <1180536987.4109.19.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-30-05 at 11:40 +0200, Patrick McHardy wrote:
> 
>>One good thing about ESFQ is the more flexible flow classification, but
>>I don't like the concept of having a set of selectable hash functions
>>very much.
>>
> 
> 
> In the spirit of SFQ it is probably ok to do that; 
> [..]
> So if you want to keep that spirit it is ok to do what ESFQ does;
> I think the assumptions will still be valid if you have a gazillion
> queues in todays terms. A number like say 128K may make sense.


Sure. The thing I don't like about the predefined hash functions is
that its unflexible.

>>These patches change SFQ to allow attaching external classifiers and add
>>a new "flow" classifier that allows to classify flows based on an arbitary
>>combination of pre-defined keys. Its probably not the fastest classifier
>>when used with multiple keys, but frankly, I don't think speed is very
>>important in most situations where the current SFQ implementation is used.
> 
> 
> The only one thing i noticed that changes the behavior is the use of
> skb->prio as a selector. I think if you removed that it should be fine.


I don't think thats a problem, it needs to point to the correct major
to have any effect, which can only happen if it is set by the user.
I would prefer to keep it for consistency with other qdiscs.

> Another alternative is to create a brand new FQ qdisc and leave the
> classification to the classifiers.


I created a new classifier to leave classification to the classifiers ..
Not sure exactly why I would need a new qdisc to do that :)

>>It currently does not support perturbation, I didn't want to move this into
>>the classifier, so I need to think about a way to handle it within SFQ.
> 
> 
> It is kind of hard to put it back into the current approach because the
> basic assumptions of ensuring no re-ordering and a "fast" classifier are
> gone.


It doesn't affect performance in any way, but I agree that it doesn't
belong in a classifier. But it should be possible to do it in SFQ.

> I am almost tempted to say go back and write a qdisc called FQ.


Funny, last the this came up you suggested to do basically exactly
what this classifier does, which I thought made sense :)

http://www.mail-archive.com/netdev@vger.kernel.org/msg06801.html
