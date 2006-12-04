From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] Optimize policy dumping
Date: Mon, 04 Dec 2006 15:26:12 +0100
Message-ID: <45743004.8050606@trash.net>
References: <1165158707.3517.92.camel@localhost>	 <45741386.5070002@trash.net> <1165238776.3664.40.camel@localhost>	 <45742825.8040004@trash.net>  <45742964.9000905@trash.net>	 <1165240725.3664.72.camel@localhost>  <45742B6D.7010509@trash.net> <1165241469.3664.81.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54451 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S936892AbWLDOXF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Dec 2006 09:23:05 -0500
To: hadi@cyberus.ca
In-Reply-To: <1165241469.3664.81.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Mon, 2006-04-12 at 15:06 +0100, Patrick McHardy wrote:
> 
> 
>>Both ways are fine I guess. But the counting has almost no
>>overhead with the patch I sent, so I'm not sure if its worth
>>adding a callback (which still needs to get the last policy/SA
>>as argument, so that part won't get any nicer).
>>
>
> The only arguement for the callback is it will lead to eventually
> having some semi-reliable dump for pfkey. But i think that is a separate
> issue to be tackled later.

Agreed, that also looks a bit tricker than the optimization.

> I am actually scratching my head a little as to what happens when the
> pfkey socket recv is full.

dump_sp() doesn't check the return value of pfkey_broadcast, so I
guess it will just try to stuff more and more data in the recv queue,
leading to either all messages after the last one fitting getting
dropped or random drops if dumping and reading happen in parallel.

setkey will loop forever if it doesn't receive the zero sequence
number.
