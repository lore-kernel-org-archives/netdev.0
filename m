From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: dev_alloc_skb and latency issues
Date: Tue, 26 Oct 2010 10:04:56 +0200
Message-ID: <AANLkTikzQw3gHT8RZUD4cnGny5Xwh6_X==zFXBfi5muS@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:45996 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750970Ab0JZIE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 04:04:57 -0400
Received: by wwe15 with SMTP id 15so4451764wwe.1
        for <netdev@vger.kernel.org>; Tue, 26 Oct 2010 01:04:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Everyone !

I am new to this mailing list, and I hope this kind of question hasn't
already been solved before (didn't find anything in the archives...).
I am facing some latency issues in the network layer (I am using a
bridge in order to transmit data between one interface to another).

I am focusing on allocation of memory using alloc_skb for *every* new
packet, and freeing of each packet before receiving a new one.
My use case is quite easy : I always have similar packets (some bytes
are changed, but the size is the same).
I don't think I am the only one with such a use case, and am thinking
about an optimization in this case (probably for others too) : why do
we have to allocate using kmem_cache for all the new packets ?

We could probably use a little piece of code which would reuse the
buffer if it hasn't to be used by anyone else.
I am thinking that if the buffer is ready to be freed (in kfree_skb or
skb_release_all for instance) then, mark the skb as "free" but do not
actually free memory.
On the next dev_alloc_skb, check this mark, and if it is present, do
not allocate, and just "memset" the skb.

This would be in my point of view really efficient when packets are similar.
Anyway, you probably have ideas about that stuff, and I am waiting for
your advices about that :).

Thanks in advance,
Best Regards,
JM
