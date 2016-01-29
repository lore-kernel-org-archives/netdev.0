From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [RFC PATCH net-next 0/3] sctp: add GSO support
Date: Fri, 29 Jan 2016 15:57:59 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D1CCD11AF@AcuExch.aculab.com>
References: <cover.1453913331.git.marcelo.leitner@gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCCEDE4@AcuExch.aculab.com>
 <20160128155323.GB6602@mrl.redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6D1CCD0160@AcuExch.aculab.com>
 <20160128205551.GC6602@mrl.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>,
	David Miller <davem@davemloft.net>,
	"brouer@redhat.com" <brouer@redhat.com>,
	"alexander.duyck@gmail.com" <alexander.duyck@gmail.com>,
	"alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
	"borkmann@iogearbox.net" <borkmann@iogearbox.net>,
	"marek@cloudflare.com" <marek@cloudflare.com>,
	"hannes@stressinduktion.org" <hannes@stressinduktion.org>,
	"fw@strlen.de" <fw@strlen.de>,
	"pabeni@redhat.com" <pabeni@redhat.com>,
	"john.r.fastabend@intel.com" <john.r.fastabend@intel.com>,
	"linux-sctp@vger.kernel.org" <linux-sctp@vger.kernel.org>
To: 'Marcelo Ricardo Leitner' <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.192]:62675 "EHLO
	smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756525AbcA2QBE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 11:01:04 -0500
In-Reply-To: <20160128205551.GC6602@mrl.redhat.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: 'Marcelo Ricardo Leitner'
> Sent: 28 January 2016 20:56
...
> > > > I did wonder whether the queued data could actually be picked up
> > > > be a Heartbeat chunk that is probing a different remote address
> > > > (which would be bad news).
> > >
> > > I don't follow. You mean if a heartbeat may get stuck in queue or if
> > > sending of a heartbeat can end up carrying additional data by accident?
> >
> > My suspicion was that the heartbeat would carry the queued data.
> 
> I'm afraid I'm  still not following, sorry. You mean that this GSO patch
> would cause the heartbeat to carry queued data? If yes, no, because for
> SCTP side of it it mangles the packet size and make it look bigger
> instead of handling multiple packets. It will then break this large
> sctp_packet into several sk_buff and glue them together as if they were
> GROed, allowing skb_segment to just split them back. The reason the
> sctp_packet is generated, being it due to user data or control chunks
> like heartbeats, is not modified.

I'm thinking of the code prior to your GSO changes.

IIRC with nagle enabled data chunks are built and put onto an
internal queue to be sent later (with nagle disabled they are
sent at the end of the tx processing provided (IIRC) there is window).
Any message that forces a transmit picks up the queued data - and
I think this might include heartbeats....

I didn't read the code closely enough to find out whether this
was true or not.

	David
