From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: Re: packet socket can't steal packets
Date: Tue, 7 May 2002 20:39:35 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10205072031400.9591-100000@mausmaki.cosy.sbg.ac.at>
References: <Pine.OSF.4.30.0205072125330.30796-100000@kosh.hut.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com
Return-path: <owner-netdev@oss.sgi.com>
To: Dmitrii Tisnek <dima@cc.hut.fi>
In-Reply-To: <Pine.OSF.4.30.0205072125330.30796-100000@kosh.hut.fi>
List-Id: netdev.vger.kernel.org

On Tue, 7 May 2002, Dmitrii Tisnek wrote:

> On Tue, 7 May 2002, Thomas 'Dent' Mirlacher wrote:
> >
> > > unless I missed something, perhaps there could be an ioctl/setsockopt
> > > which would turn this behaviour into "pass packet to user mode or drop
> > > altogether" that would never result in network stack getting a packet
> > > directly.
> >
> > well, that would be nice for certain applications, but wouldn't it
> > also be a security problem?
> 
> no.
> 
> read-only access to network traffic already requires priviledges.
> and theres' already a way to insert packets via socket send/write.

seen from this perspective you're right.
and seen from the perspective that the kernel should provide functionality
	and the user/admin is responsible for restricting this access,
	you're right too.

> all I'm proposing is a way to "delete" packets too.

well you've a problem here:
	1)	how can you be sure you're the first one to see that packet?
		what about two applications which want to do the same thing?
		should tcpdump (on the local machine of course :) see the
			packet at all?
and the really minor problem is, you've to change all the protocols which
register + af_packet to return an NET_RX_DONTCARE instead of NET_RX_DROP.

	just my $0.02

		++dent
	
-- 
in some way i do, and in some way i don't.
