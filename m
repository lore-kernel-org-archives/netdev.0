From: Florent Fourcot <florent.fourcot@enst-bretagne.fr>
Subject: Re: [PATCH 2/2] ipv6: Set flow label to skb_hash on transmit
Date: Mon, 28 Apr 2014 21:37:33 +0200
Message-ID: <535EADFD.4050508@enst-bretagne.fr>
References: <alpine.DEB.2.02.1404261553180.15772@tomh.mtv.corp.google.com>	<535E99F3.3050404@enst-bretagne.fr> <CA+mtBx-umd3vmNggurFiugQXr_gb+14HvHo=jdaPnpC4cL=tdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fourcot.fr ([217.70.191.14]:51596 "EHLO olfflo.fourcot.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753702AbaD1Thg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2014 15:37:36 -0400
In-Reply-To: <CA+mtBx-umd3vmNggurFiugQXr_gb+14HvHo=jdaPnpC4cL=tdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>>
>> By enabling auto_flowlabels, we can have conflict between the flow label
>> manager policy, and a randomly generated label.
>>
> What would be the consequences of such a conflict? Per RFC6437
> stateless and stateful flow labels are selected from the same space,
> the probability of collision between them is assumed to be non-zero.
> We obviously can't make any assumptions on RX.
> 

In the new RFC world, perhaps. But the flow label manager is older than
that, and implement a strong policy on flow labels.
Since we cannot know who is using it, and how there are using it, I'm
against this new behaviour. Disabling the manager is ok for me, but not
by default.

As second point, the name of auto_flowlabel is in my opinion not a
perfect choice if you set a label it only on tunnels. This is exactly
the same name that a BSD sysctl, setting a random label on all sockets
(TCP, UDP...). The flow label world is already hard enough to
understand, thanks to various implementations.

Regards,

-- 
Florent.
