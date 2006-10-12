From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 12:36:14 +0200
Message-ID: <200610121236.14424.dada1@cosmosbay.com>
References: <000201c6ede7$0ef3e110$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:27029 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1751192AbWJLKgM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 06:36:12 -0400
To: "Martin Schiller" <mschiller@tdt.de>
In-Reply-To: <000201c6ede7$0ef3e110$1a04010a@V505CP>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 October 2006 12:13, Martin Schiller wrote:
> On Thursday, October 12, 2006 10:38 AM, Eric Dumazet wrote:
> > Well, it is already possible to delay the 'third packet' of an
> > outgoing connection with a litle hack. But AFAIK not the SYNACK of
> > incoming connection. It could be cool. Maybe some new syscalls are
> > needed:
> >
> > int syn_recv(int socklisten, ...);
> > /* give to user app the SYN packet */
> > int syn_ack(int socklisten, ...);
> > /* User app has the ability to ask kernel tcp stack to :
> >     DROP this packet.
> >     REJECT the attempt
> >     ACCEPT the attempt (sending a SYN/ACK) */
>
> So, when do you mean the user-space application should run this syscalls?
> After the call to listen()?
>

Exactly like when you call accept() on a non blocking listening socket.

If your application did asked to received notification of SYN packets, it 
should be prepared to call accept() (to be notified of fully established 
connections) and/or syn_recv() (to be notified of SYN packets)

So when poll()/select()/epoll() tells your socklisten has available events, 
your application would have to call both accept() and syn_recv() in a loop to 
empty all awaiting events.

> Another problem with this solution might be, that I don't want to block the
> listening socket with the processing of one request, because there could be
> a lot of simultaneous requests.

Yes I can imagine.
