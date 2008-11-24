From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2] pkt_sched: sch_drr: Fix drr_dequeue() loop
Date: Mon, 24 Nov 2008 13:45:16 +0000
Message-ID: <20081124134516.GD16755@ff.dom.local>
References: <20081120113557.GA5275@ff.dom.local> <49254D42.10506@trash.net> <20081124105345.GB13957@ff.dom.local> <492A9ACB.4050504@trash.net> <20081124123349.GA16755@ff.dom.local> <492AA058.9060302@trash.net> <20081124125150.GB16755@ff.dom.local> <492AA96C.6000807@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.183]:57079 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbYKXNpW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 08:45:22 -0500
Received: by ik-out-1112.google.com with SMTP id c29so1641645ika.5
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 05:45:20 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <492AA96C.6000807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 24, 2008 at 02:17:32PM +0100, Patrick McHardy wrote:
> Jarek Poplawski wrote:
>> On Mon, Nov 24, 2008 at 01:38:48PM +0100, Patrick McHardy wrote:
>> ...
>>> TBF with an inner DRR is fine. The other way around is broken
>>> in the sense that the behaviour is undefined.
>>
>> IMHO, this other way (e.g. a class with TBF per user), should work too.
>
> The behaviour undefined, so what does "work too" mean in this context?
>
> The main question is: what should be done with the class when it
> throttles?
>
> You suggest moving it to the end of the active list. Should its deficit
> be recharged in that case? Possible no because it didn't send packets -
> but then again it might have handed out *some* packets (less than the
> deficit) before it started throttling. Both ways would introduce
> unfairness.
>
> What could be done without harming the algorithm is to treat throttled
> classes as inactive until they become unthrottled again, meaning they
> would be added to the end of the active list with a full deficit. But
> we have no indication for specific classes, unthrottling simply triggers
> another dequeue of the root, so the implementation would get quite
> complicated, leaving alone the fact that each TBF would potentially
> start its own watchdog, causing excessive wakeups.
>
> And I don't see much use for this, what is the advantage over using
> HTB or HFSC?

Probably no advantage, if you now these things... or for testing. But
I like to give users a choice, at least if it's not obviously wrong.
Of course, if you think this harms the proper configs with too much
overhead, then there is no question we should forget about this.

Jarek P.
