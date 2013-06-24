From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: UDP splice
Date: Mon, 24 Jun 2013 17:02:56 +0100
Message-ID: <1372089776.1896.9.camel@bwh-desktop.uk.level5networks.com>
References: <CACYKsS7pMFNdBxU2raMphKyb1zU7MEbhc=vsD+FdZ5sgFq71NQ@mail.gmail.com>
	 <1372088554.1896.3.camel@bwh-desktop.uk.level5networks.com>
	 <20130624155154.GD10413@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Ricardo Landim <ricardolan@gmail.com>, <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:13503 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750884Ab3FXQDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 12:03:01 -0400
In-Reply-To: <20130624155154.GD10413@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-06-24 at 17:51 +0200, Hannes Frederic Sowa wrote:
> On Mon, Jun 24, 2013 at 04:42:34PM +0100, Ben Hutchings wrote:
> > On Fri, 2013-06-21 at 07:04 -0300, Ricardo Landim wrote:
> > > Hi folks,
> > > 
> > > I am developing a RTP proxy for voip applications and tried use the
> > > splice syscall
> > > for zero copy. I am trying splice udp data to pipe and splice pipe to udp
> > > socket.
> > > 
> > > I read some information of the splice function and reading the kernel
> > > source code I saw this lines in net/ipv4/af_inet.c
> > > 
> > > const struct proto_ops inet_stream_ops = {
> > > ...
> > >     .splice_read = tcp_splice_read,
> > > ...
> > > }
> > > 
> > > const struct proto_ops inet_dgram_ops = {
> > > ...
> > > ...
> > > }
> > > 
> > > There is an implementation of splice for TCP socket but not for UDP socket.
> > > 
> > > My question is: there is some limitation in UDP socket that prevents this
> > > implementation?
> > 
> > splice() works with streams, but UDP is a message-oriented protocol.
> > How would a UDP implementation of splice() decide where to put the
> > message boundaries, or to distinguish the messages?
> 
> Splicing a pipe to udp socket should work nontheless. Splicing from udp socket
> to pipe does not work.

Should it?  I suppose it could work for UDP-based protocols that include
their own framing, but I can't see that it's generally useful.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
