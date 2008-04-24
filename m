From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH v2] Re: WAN: new PPP code for generic HDLC
Date: Thu, 24 Apr 2008 15:12:17 +0200
Message-ID: <m3r6cv75xq.fsf@maximus.localdomain>
References: <m34p9smrmp.fsf@maximus.localdomain>
	<20080423.154953.161012169.davem@davemloft.net>
	<m3iqy8f57m.fsf@maximus.localdomain>
	<20080423.180849.240014014.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeff@garzik.org, paulkf@microgate.com, jchapman@katalix.com,
	alan@lxorguk.ukuu.org.uk, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:44374 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752484AbYDXNMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Apr 2008 09:12:19 -0400
In-Reply-To: <20080423.180849.240014014.davem@davemloft.net> (David Miller's message of "Wed\, 23 Apr 2008 18\:08\:49 -0700 \(PDT\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> The core kernel code sets dev->priv to the alloc_netdev() allocated
> memory region.
>
> It doesn't do that just for fun.
>
> Any code which overrides that setting is asking for trouble.
> What if the code kernel code that set it, needed to use it
> during device release for some reason?

You are right, the point is Linux is a moving target, and I try to
write code as good as I can in given circumstances but never better.
I accept occasional breakage in obscure cases like syncppp+hdlc,
but I also need a way to fix it and/or remove the obscureness (or
whatever the right word is).

Historically we always have had two pointers:
- dev->priv
- first we had struct (net_)device *dev and by embedding it in larger
  structure we were able to have another private data area (even with
  Space.c)
- then netdev_alloc() and netdev_priv() came
- since 2.6.23 netdev_priv() returns dev->priv - one pointer is gone.

Anyway, I guess we should rather concentrate on what to do now with
the thing. Perhaps you have some idea?
-- 
Krzysztof Halasa
