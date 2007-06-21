From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] NET: Multiqueue network device support.
Date: Thu, 21 Jun 2007 11:39:48 -0400
Message-ID: <1182440388.5017.31.camel@localhost>
References: <466DEF9D.9070509@trash.net>
	 <1181615384.4071.121.camel@localhost>	<466E9DF2.9010505@trash.net>
	 <20070612.140240.00078635.davem@davemloft.net> <466F0D74.5030308@trash.net>
	 <1181714168.4758.57.camel@debian.sh.intel.com>
	 <1181737935.4050.87.camel@localhost>
	 <1181789064.4758.127.camel@debian.sh.intel.com>
	 <1181821707.4091.32.camel@localhost>
	 <1181870826.4092.29.camel@debian.sh.intel.com>
	 <1181904575.4102.31.camel@localhost>
	 <1182129521.4092.77.camel@debian.sh.intel.com>
	 <1182179770.4063.26.camel@localhost>
	 <1182219120.4092.143.camel@debian.sh.intel.com>
	 <1182269060.4968.45.camel@localhost>
	 <1182318706.4092.255.camel@debian.sh.intel.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org,
	jeff@garzik.org, auke-jan.h.kok@intel.com
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wr-out-0506.google.com ([64.233.184.235]:36618 "EHLO
	wr-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250AbXFUPjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 11:39:55 -0400
Received: by wr-out-0506.google.com with SMTP id q50so495247wrq
        for <netdev@vger.kernel.org>; Thu, 21 Jun 2007 08:39:54 -0700 (PDT)
In-Reply-To: <1182318706.4092.255.camel@debian.sh.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


I gave you two opportunities to bail out of this discussion, i am gonna
take that your rejection to that offer implies you my friend wants to
get to the bottom of this i.e you are on a mission to find the truth.
So lets continue this.

On Wed, 2007-20-06 at 13:51 +0800, Zhu Yi wrote:

> No, because this is over-engineered. 
> Furthermore, don't you think the
> algorithm is complicated and unnecessary (i.e. one timer per h/w queue)?

The (one-shot) timer is only necessary when a ring shuts down the
driver. This is only for the case of wireless media. Standard Wired
Ethernet doesnt need it.

Note: You are not going to convince me by throwing cliches like "this is
over-engineering" around. Because it leads to a response like "Not at
all. I think Sending flow control messages back to the stack is
over-engineering. " And where do we go then?

> Do you think the driver maintainer will accept such kind of workaround
> patch? 

Give me access to your manual for the chip on my laptop wireless which
is 3945ABG and i can produce a very simple patch for you. Actually if
you answer some questions for me, it may be good enough to produce such
a patch.

> You did too much to keep the Qdisc interface untouched!

What metric do you want to define for "too much" - lines of code?
Complexity? I consider architecture cleanliness to be more important.

> Besides, the lower THL you choose, the more CPU time is wasted in busy
> loop for the only PL case; 

Your choice of THL and THH has nothing to do with what i am proposing.
I am not proposing you even touch that. What numbers do you have today?

What i am saying is you use _some_ value for opening up the driver; some
enlightened drivers such as the tg3 (and the e1000 - for which i
unashamedly take credit) do have such parametrization. This has already
been proven to be valuable.

The timer fires only if a ring shuts down the interface. Where is the
busy loop? If packets go out, there is no timer.
 
> the higher THL you choose, the slower the PH
> packets will be sent out than expected (the driver doesn't fully utilize
> the device function -- multiple rings, 

I dont think you understood: Whatever value you choose for THL and THH
today, keep those. OTOH, the wake threshold is what i was refering to.

> which conlicts with a device driver's intention). 

I dont see how given i am talking about wake thresholds.

> You can never make a good trade off in this model.

Refer to above.

> I think I have fully understood you, 

Thanks for coming such a long way - you stated it couldnt be done before
unless you sent feedback to the stack.

> but your point is invalid. The
> Qdisc must be changed to have the hardware queue information to support
> multiple hardware queues devices.
> 

Handwaving as above doesnt add value to a discussion. If you want
meaningful discussions, stop these cliches.

cheers,
jamal

