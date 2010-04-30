From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH] tcp: SO_TIMESTAMP implementation for TCP
Date: Fri, 30 Apr 2010 00:58:32 -0700
Message-ID: <i2i65634d661004300058s5ee1b177oee249d3d22baad62@mail.gmail.com>
References: <alpine.DEB.1.00.1004292246440.12776@pokey.mtv.corp.google.com>
	 <20100429.233958.212393607.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:16611 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758095Ab0D3RAL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 13:00:11 -0400
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id o3U7wZ4N003362
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 00:58:35 -0700
Received: from pvc7 (pvc7.prod.google.com [10.241.209.135])
	by wpaz29.hot.corp.google.com with ESMTP id o3U7wWAS026605
	for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 00:58:34 -0700
Received: by pvc7 with SMTP id 7so939661pvc.29
        for <netdev@vger.kernel.org>; Fri, 30 Apr 2010 00:58:32 -0700 (PDT)
In-Reply-To: <20100429.233958.212393607.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> That's not what you're implementing here.
>
> You're only updating the socket timestamp if the SKB passed into
> the update function has a more recent timestamp.
>
Yes that is the intent.  This provides a measure time from when all
the data in the recvmsg is present on the socket and when the
application actually consumes it.  It has been quite useful for
demonstrating to apps writers when their application is being slow to
read the data, as opposed to the stack being slow.

> There is nothing that says the timestamps have to be increasing and
> with retransmits and such if it were me I would want to see the real
> timestamp even if it was earlier than the most recently reported
> timestamp.
>
> I don't know, I really don't like this feature at all. =A0SO_TIMESTAM=
P
> is really meant for datagram oriented sockets, where there is a
> clearly defined "packet" whose timestamp you get. =A0A TCP receive ca=
n
> involve hundreds of tiny packets so the timestamp can lack any
> meaning.
>
And a UDP datagram could be composed of hundreds of IP fragments, so
there's still no clear definition of a "packet"...  in fact the choice
of which skb to use as the representative timestamp seems pretty
arbitrary (if the semantics of the timestamp is for when the "datagram
is received", I would think that is when reassembly is complete, i.e.
timestamp of last packet received).

> All these new checks and branches for a feature of questionable value=
=2E

> If you can modify you apps to grab this information you can also prob=
e
> for the information using external probing tools.
>
I don't see an nice way to do that, we're profiling a significant
percentage of millions of connections over thousands of paths as part
of standard operations while incurring negligible overhead.  The app
can can easily timestamp its operations, but without some mechanism
for getting timestamps out of a TCP connection, the networking portion
of servicing requests is pretty much a black box in that.

> Sorry, I don't think I'll be applying this.
>
Thanks for consideration!

Tom
