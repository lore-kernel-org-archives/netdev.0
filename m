From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC NET_SCHED 00/02]: Flexible SFQ flow classification
Date: Wed, 30 May 2007 18:23:05 +0200
Message-ID: <465DA4E9.5060906@trash.net>
References: <20070530094020.24073.84277.sendpatchset@localhost.localdomain>	 <1180536987.4109.19.camel@localhost>  <465D97F1.9090600@trash.net> <1180541401.4109.72.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43068 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750749AbXE3QXJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 May 2007 12:23:09 -0400
In-Reply-To: <1180541401.4109.72.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Wed, 2007-30-05 at 17:27 +0200, Patrick McHardy wrote:
> 
>>>Another alternative is to create a brand new FQ qdisc and leave the
>>>classification to the classifiers.
>>
>>I created a new classifier to leave classification to the classifiers ..
>>Not sure exactly why I would need a new qdisc to do that :)
>>
> 
> 
> The caveat/difference with current SFQ is you have allowed the user to
> define which queue is selected.


I think exposing SFQ's queues as classes is a good thing, it allows
you to do whatever classification you want. In fact I'm probably
going to add patch on top to also dump them to userspace. What
remains for SFQ to do is serve the queues evenly.

> It is/was dynamically selected based on
> packet header now/before. Thats the main reason i said maybe you
> separate the two components totaly. i.e while FQ is useful on its own
> and can use other classifiers; a useful classifier IMO for SFQ is one
> that rips out the sfq_hash or whatever other schemes used in ESFQ into a
> classifier (I suppose then the user can select which hash is used). In
> such a classifier you can restore the pertub into it.
> I am not sure i made sense.


My classifier seperates them entirely. The only thing it keeps
in SFQ is the old classifier for compatibility, besides that its
exactly what you say. It should be easily possible to remove it
entirely and use my classifier in a compatible configuration
automatically.

>>>I am almost tempted to say go back and write a qdisc called FQ.
>>
>>
>>Funny, last the this came up you suggested to do basically exactly
>>what this classifier does, which I thought made sense :)
>>
>>http://www.mail-archive.com/netdev@vger.kernel.org/msg06801.html
> 
> 
> I am almost sensing i am contradicting myself in that thread;-> It is
> hard to tell and i admit to being forgetful - but what i probably meant
> is what i said above. 


I'm sensing you didn't look at the patch :)
