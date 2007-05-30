From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 10:56:27 -0400
Message-ID: <1180536987.4109.19.camel@localhost>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.225]:3890 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751995AbXE3O43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 10:56:29 -0400
Received: by wx-out-0506.google.com with SMTP id t15so1794114wxc
        for <netdev@vger.kernel.org>; Wed, 30 May 2007 07:56:29 -0700 (PDT)
In-Reply-To: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2007-30-05 at 11:40 +0200, Patrick McHardy wrote:
> One good thing about ESFQ is the more flexible flow classification, but
> I don't like the concept of having a set of selectable hash functions
> very much.
> 

In the spirit of SFQ it is probably ok to do that; 
i.e iirc,  the idea for justification behind sfq was to provide a
"computationaly feasible/reasonable" way to provide fair queueing with a
gazillion queues. 
Classification was considered damn expensive in those days (when MC68K
was sort of state of the art); it still is but maybe a much much lesser
issue now for what "gazillion" was in those days. So a simple hash on a
few fields with pertubation (the part that makes allows the "stochastic"
part in the name) was deemed the way to go and in order to provide
fairness (while avoiding packet reordering).
So if you want to keep that spirit it is ok to do what ESFQ does;
I think the assumptions will still be valid if you have a gazillion
queues in todays terms. A number like say 128K may make sense.
(Hey Paul M is still around, just too focused on the wrong things like
RCU;-> so we can ask his opinion)

> These patches change SFQ to allow attaching external classifiers and add
> a new "flow" classifier that allows to classify flows based on an arbitary
> combination of pre-defined keys. Its probably not the fastest classifier
> when used with multiple keys, but frankly, I don't think speed is very
> important in most situations where the current SFQ implementation is used.

The only one thing i noticed that changes the behavior is the use of
skb->prio as a selector. I think if you removed that it should be fine.
Another alternative is to create a brand new FQ qdisc and leave the
classification to the classifiers.

> It currently does not support perturbation, I didn't want to move this into
> the classifier, so I need to think about a way to handle it within SFQ.

It is kind of hard to put it back into the current approach because the
basic assumptions of ensuring no re-ordering and a "fast" classifier are
gone.

I am almost tempted to say go back and write a qdisc called FQ.

cheers,
jamal

