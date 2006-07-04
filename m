From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Wed, 05 Jul 2006 01:53:46 +0200
Message-ID: <44AAFF8A.9080201@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150287983.3246.27.camel@ras.pc.brisbane.lube>	 <1150292693.5197.1.camel@jzny2>	 <1150843471.17455.2.camel@ras.pc.brisbane.lube>	 <15653CE98281AD4FBD7F70BCEE3666E53CD54A@comxexch01.comx.local>	 <1151000966.5392.34.camel@jzny2>	 <1151066247.4217.254.camel@ras.pc.brisbane.lube>	 <449C06E3.3090406@trash.net>	 <1151282720.4210.46.camel@ras.pc.brisbane.lube>	 <449FC0AF.1050904@trash.net> <44A0CE01.4010109@stuart.id.au>	 <44AA6D25.9000707@trash.net> <1152041373.5276.36.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <hawk@diku.dk>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@osdl.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Russell Stuart <russell-tcatm@stuart.id.au>,
	Russell Stuart <russell@stuart.id.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:19426 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S932320AbWGDXzG
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jul 2006 19:55:06 -0400
To: hadi@cyberus.ca
In-Reply-To: <1152041373.5276.36.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2006-04-07 at 15:29 +0200, Patrick McHardy wrote:
> 
>>Russell Stuart wrote:
> 
> [..]
> 
>>>Without seeing your actual proposal it is difficult to
>>>judge whether this is a reasonable trade-off or not.
>>>Hopefully we will see your code soon.  Do you have any
>>>idea when?
>>
>>Unfortunately I still didn't got to cleaning them up, so I'm sending
>>them in their preliminary state. Its not much that is missing, but
>>the netem usage of skb->cb needs to be integrated better, I failed
>>to move it to the qdisc_skb_cb so far because of circular includes.
>>But nothing unfixable. I'm mostly interested if the current size-tables
>>can express what you need for ATM, I wasn't able to understand the
>>big comment in tc_core.c in your patch.
>>
> 
> 
> Looks good from within the range of "change within reason" of addressed
> problem. The cb on the qdisc seems only usable for netem, correct?

Yes, it has the same limitations as current netem cb usage. Really
makeing it useable for all qdiscs would require reserving a few bytes
for every level, so far that isn't necessary and I would prefer to
just add a time_to_send field for netem. The problem with this is
that it currently requires sch_generic.h and pkt_sched.h to include
one another, so I did the qdisc_skb_cb() thing to at least get it to
compile for now.

> Also while not unreasonable, i wasnt sure how qdisc_enqueue_root()
> fit in the grand scheme of things for this change (it seemed out of
> place).

Its there as a spot to do the initial time calculations and store them
in the cb. I didn't want to put this in net/core/dev.c.

