From: Tom Herbert <therbert@google.com>
Subject: Re: Generalizing mmap'ed sockets
Date: Fri, 19 Nov 2010 14:49:46 -0800
Message-ID: <AANLkTik7HU0wyub3krZb_aABsHp-_LvNLtAr5CaAo4_A@mail.gmail.com>
References: <4CE6ED09.70602@hp.com>
	<20101119.135213.15239226.davem@davemloft.net>
	<4CE6F2FD.8080301@hp.com>
	<20101119.140818.242132853.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:23261 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757161Ab0KSWuB convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 17:50:01 -0500
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id oAJMo0Vg003811
	for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 14:50:00 -0800
Received: from pvg2 (pvg2.prod.google.com [10.241.210.130])
	by kpbe15.cbf.corp.google.com with ESMTP id oAJMnkpd004590
	for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 14:49:57 -0800
Received: by pvg2 with SMTP id 2so1439314pvg.2
        for <netdev@vger.kernel.org>; Fri, 19 Nov 2010 14:49:46 -0800 (PST)
In-Reply-To: <20101119.140818.242132853.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I think the ACK (or for UDP, the kfree_skb() after TX completes) shou=
ld
> move the consumer pointer. =A0Otherwise you have to copy, and the ACK=
s
> do not clock the sender process properly.
>
Right, with the caveats that even ACK'ed data might still go out on
the with that was discussed in the vmsplice() related patches.  I
don't think this should make the problem any worse.

> But you do bring up an interesting point about TX buffer space sizing=
=2E
>
> This whole scheme currently seems to completely ignore buffer size
> auto-tuning done by TCP, and that won't fly I think. :-)
>
> The whole point is to make it so that applications do not need to kno=
w
> about that aspect of buffering at all. =A0With the current mmap desig=
n
> we're back to the stone ages where the app essentially has to pick an
> explicit send buffer size.

True, and I would never say that this is suitable replacement for all
TCP transmit.  However, there are specialized applications where this
could be applied.  Note that the buffer is not just a kernel buffer,
it is also an application visible buffer with more purpose than just
buffering data for transmit.  For instance, an application using RPC
could assemble it's message directly into this buffer (which is cool).
 The obvious alternative would be to malloc a buffer and then just use
vmsplice(), either way the application will be allocating a send
buffer for its work.

Tom
