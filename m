From: Andrew Gallatin <gallatin@myri.com>
Subject: Re: [PATCH] LRO ack aggregation
Date: Tue, 20 Nov 2007 06:47:57 -0500
Message-ID: <4742C96D.3050203@myri.com>
References: <20071119.210919.177660672.davem@davemloft.net>	<E1IuMIQ-0003gc-00@gondolin.me.apana.org.au> <20071119.222214.81458569.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailbox2.myri.com ([64.172.73.26]:1835 "EHLO myri.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756037AbXKTLvz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Nov 2007 06:51:55 -0500
In-Reply-To: <20071119.222214.81458569.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
 > From: Herbert Xu <herbert@gondor.apana.org.au>
 > Date: Tue, 20 Nov 2007 14:09:18 +0800
 >
 >> David Miller <davem@davemloft.net> wrote:
 >>> Fundamentally, I really don't like this change, it batches to the
 >>> point where it begins to erode the natural ACK clocking of TCP, and I
 >>> therefore am very likely to revert it before merging to Linus.
 >> Perhaps make it a tunable that defaults to off?
 >
 > That's one idea.

I'd certainly prefer the option to have a tunable to having our
customers see performance regressions when they switch to
the kernel's LRO.

 > But if it's there the risk it to have it end up being turned on
 > always by distribution vendors, making our off-default pointless
 > and the internet gets crapped up with misbehaving Linux TCP
 > stacks anyways.

If vendors are going to pick this up, there is the risk of them just
applying this patch (which currently has no tunable to disable it),
leaving their users stuck with it enabled.  At least with a tunable,
it would be easy for them to turn it off.  And the comments surrounding
it could make it clear why it should default to off.

FWIW, we've seen TCP perform well in a WAN setting using our NICs and
our LRO which does this ack aggregation.  For example, the last 2
Supercomputing "Bandwidth Challenges" (making the most of a 10Gb/s
WAN connection) were won by teams using our NICs, with drivers that
did this sort of ack aggregation.

Drew
