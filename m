From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/6] Add qdisc->ops->peek() support.
Date: Thu, 16 Oct 2008 14:38:31 +0200
Message-ID: <48F735C7.6050808@trash.net>
References: <20081016094645.GA19019@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32807 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751029AbYJPMif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 08:38:35 -0400
In-Reply-To: <20081016094645.GA19019@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> So here is my try (I hope I didn't miss Patrick's intentions to much).
> 
> PATCH 6/6 adds my simple idea not to prevent even nonsense configs.
> It is optional.

These patches look good to me. About 6/6, I'm still thinking we
might want to prevent certain kinds of nonsensical configurations
for simplicity. Its a bit similar to the multiq stuff, a lot of
these complications came from the fact that non-work-conserving
qdiscs, which require a global view, are treated similar to work-
conserving ones. I don't have a good scheme worked out though,
so for now using your patch seems OK too.

> PS: after this patchset only netem_enqueue() needs qdisc->requeue(),
> but I hope this won't take too long.

Assuming work-conserving qdiscs are used with netem, the currently
code will always send out a reorder packet immediately. This behaviour
is trivial to implement without ->requeue. The problematic case is
non-work-conserving inner qdiscs, but that doesn't seem important
at all since you'd usually add it as parent of netem, which still
works.
