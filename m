From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [net PATCH] flow_dissector: Fix unaligned access in
 __skb_flow_dissector when used by eth_get_headlen
Date: Mon, 1 Feb 2016 16:50:29 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD25A8@AcuExch.aculab.com>
References: <CAKgT0UcZAh+ciNMkJDdnp7E0xyGMhvgSzJLwORLqYXbpABtoRQ@mail.gmail.com>
	<1454182011.7627.141.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAKgT0UfyK1HO6vp4F9S3rB400A74OhS=qRX_N9RuPRYg2KazLg@mail.gmail.com>
 <20160130.194507.777391919166997236.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	"sowmini.varadhan@oracle.com" <sowmini.varadhan@oracle.com>,
	"aduyck@mirantis.com" <aduyck@mirantis.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"tom@herbertland.com" <tom@herbertland.com>
To: 'David Miller' <davem@davemloft.net>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.187]:53905 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbcBAQxn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 11:53:43 -0500
In-Reply-To: <20160130.194507.777391919166997236.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller
> Sent: 31 January 2016 03:45
> To: alexander.duyck@gmail.com
...
> > I would really prefer to keep the pages DMA aligned, and the skb->data
> > IP aligned.  If nothing else it has the advantage of actually having
> > the proper alignment on all the headers if I only pull the outer
> > headers and leave the inner headers in the page.. :-/
> 
> I am unconvinced by your arguments.  People getting hit by these
> arguments don't care.  For those not hitting the problem, nothing is
> going to change.
> 
> x86 uses NET_IP_ALIGN==0, and therefore nothing will change for the
> only platform people care a lot about.  PowerPC too.
> 
> For platforms with NET_IP_ALIGN==2 or similar, all of these cases
> where 1K extra buffer is allocator or _whatever_ other side effect you
> think is such as huge deal...  trust me it's _nothing_ compared to the
> alternative:
> 
> 1) Unaligned accesses

Remember the even if you do a 'realignment copy' of the IP header,
at some point the 'userdata' of the packet has to be accessed.
Mostly this will be with memcpy() and you want that copy to be aligned.

I really can't believe just how many ethernet chips are now being designed
that can't write received frames to '4n+2' boundaries.
It isn't even a new problem. Sun fixed the sbus 'DMA' part so that it would
to sbus burst transfers to 4n+2 aligned buffers a long time ago...

	David
