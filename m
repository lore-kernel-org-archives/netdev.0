From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] pkt_sched: sch_netem: Limit packet re-ordering	functionality
 to tfifo qdisc.
Date: Wed, 22 Oct 2008 18:00:56 +0200
Message-ID: <48FF4E38.9010806@trash.net>
References: <20081017130333.GA8297@ff.dom.local> <48F89D33.9090809@trash.net> <20081017201210.GA2527@ami.dom.local> <20081021.163605.57275028.davem@davemloft.net> <20081021165129.422dd83f@extreme> <20081022053746.GA4178@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:55943 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751417AbYJVQA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Oct 2008 12:00:58 -0400
In-Reply-To: <20081022053746.GA4178@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> On Tue, Oct 21, 2008 at 04:51:29PM -0700, Stephen Hemminger wrote:
>> On Tue, 21 Oct 2008 16:36:05 -0700 (PDT)
>> David Miller <davem@davemloft.net> wrote:
>>
>>> sch_netem is just a black box, like any other packet scheduler node in
>>> the tree, and so it can internally do the reordering with a self managed
>>> packet list or similar.  All of this can be hidden inside of it's ->dequeue()
>>> with some pkt_sch watchdog timer that fires to prevent stale packets sitting
>>> in the reorder queue forever.
>>>
>>> Anyways, just and idea and RFC, just like this patch ;-)
>> The problem is that jamal talked me into having netem as a classful qdisc,
>> instead of doing its own rate control.  People like to do use TBF as inner qdisc,
>> and do reordering.
> 
> If it's only this kind of usage we could export tfifo and let use this
> as a TBF's (etc.) leaf. Of course, this would require changes in those
> people scripts.

In that case we might as well teach them to use TBF as *parent*
of netem (and I'd vote to do that and kill requeue).

But we can argue about this forever without any progress. The
question is simple - should we enforce a reasonable qdisc structure
and kill ->requeue or keep it around forever. Keep in mind that there
is no loss of functionality by using TBF as parent and that we
can do this gradually so users have a chance to fix their scripts,
should anyone really use TBF as inner qdisc.

