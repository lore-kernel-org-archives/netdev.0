From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] Mobile IPv6 introduction
Date: Tue, 01 Aug 2006 17:35:35 -0700 (PDT)
Message-ID: <20060801.173535.38709014.davem@davemloft.net>
References: <44CB2914.9010803@linux-ipv6.org>
	<20060729141244.GJ8334@innerghost.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nakam@linux-ipv6.org, yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi,
	vnuorval@tcs.hut.fi, netdev@vger.kernel.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:25513
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750871AbWHBAfe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 20:35:34 -0400
To: hsantos@av.it.pt
In-Reply-To: <20060729141244.GJ8334@innerghost.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hugo Santos <hsantos@av.it.pt>
Date: Sat, 29 Jul 2006 15:12:44 +0100

>    - In general, lot's of places in the IPv6 stack don't take the source
>      address into consideration and generically only use destination as
>      key, i think this is a major setback that should be approached
>      individually.

This is partly why the multiple routing table code is being
added as the initial infrastrucutre, so that source based
things are possible.

>      support), or instead introducing a new datagram control message
>      that would enable the control application to retrieve the original
>      network headers (although possibly modified) and send the ICMPv6
>      message itself (which was my choice).

Such a scheme would need provisions for handling the case where
the user eats the message, but never tells us what to do.
In such a case we'd need to emit some kind of ICMPv6 message,
even if it would be just a timeout generated parameter problem.

>    - Maybe others disagree, but i don't like having a "Route
>      optimization" mode in XFRM. From my POV, "Route optimization" is
>      one kind of transformation specific to MIPv6. Other protocols
>      require other kind of transformations. I think XFRM should be
>      instead extended to support generic transformations, where the
>      Mobile IPv6-specific one would implement a RO transform in order to
>      support it's binding cache. Also, these new modes are not
>      "advanced" but instead "Mobile IPv6 specific".

Such a layer would be needed if we ever put some kernel level
components of Mobile IPv4 into the tree, which I see no reason
not to, since it has this route optimization as well.
