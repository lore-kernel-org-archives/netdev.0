From: Bill Davidsen <davidsen@tmr.com>
Subject: Re: [2.4 PATCH] bugfix: ARP respond on all devices
Date: Tue, 19 Aug 2003 13:17:44 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.3.96.1030819125244.7550A-100000@gatekeeper.tmr.com>
References: <20030819091414.512d80c4.davem@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: willy@w.ods.org, richard@aspectgroup.co.uk, alan@lxorguk.ukuu.org.uk,
   skraw@ithnet.com, carlosev@newipnet.com, lamont@scriptkiddie.org,
   bloemsaa@xs4all.nl, marcelo@conectiva.com.br, netdev@oss.sgi.com,
   linux-net@vger.kernel.org, layes@loran.com, torvalds@osdl.org,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20030819091414.512d80c4.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 19 Aug 2003, David S. Miller wrote:

> On Tue, 19 Aug 2003 11:53:29 -0400 (EDT)
> Bill Davidsen <davidsen@tmr.com> wrote:
> 
> > I wonder if a change to add a flag preventing *any* packet from being sent
> > on a NIC which doesn't have the proper source address would be politically
> > acceptable.
> 
> This would disable things like MSG_DONTROUTE and many valid
> uses of RAW sockets.
> 

Probably would, but since it's a flag people could use it or not. I did
that via a patch and it didn't show any problems in a tcp/udp environment.
I would assume that source routing would produce the same problem in some
cases, would it not? And I bet that using rp_filter can break some things
as well, so there is precedent for having capabilities which could impact
some valid procedures.

I appreciate your point (which I totally overlooked), but I don't see that
we have avoided other capabilities which could cause problems if
misconfigured. It is clearly the responsibility of the admin to do
configuration, and this seems (based on my actual experience) to work in
an environment where arp/tcp/udp are being used.

Unless you have additional issues, I would suggest that there are good
reasons to add this capability.
- no more dangerous than source routing and much easier to use
- saves much discussion and time
- much better to have one change done properly than lots of half-assed
  patches

I understand your objections to the hidden patch, I think the approach I
suggest could be done at the proper level and would provide a standard way
to solve a common problem. If this can be reasonably done I would think
you would support it just to be able to say "use default_source_routing"
when the hidden patch visits the next time ;-)

-- 
bill davidsen <davidsen@tmr.com>
  CTO, TMR Associates, Inc
Doing interesting things with little computers since 1979.
