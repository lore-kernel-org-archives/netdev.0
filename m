From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 14:31:02 +0400
Message-ID: <20061012103102.GA17891@2ka.mipt.ru>
References: <200610121038.18309.dada1@cosmosbay.com> <000201c6ede7$0ef3e110$1a04010a@V505CP>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "'Eric Dumazet'" <dada1@cosmosbay.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:34711 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1161560AbWJLKb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 06:31:28 -0400
To: Martin Schiller <mschiller@tdt.de>
Content-Disposition: inline
In-Reply-To: <000201c6ede7$0ef3e110$1a04010a@V505CP>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 12, 2006 at 12:13:26PM +0200, Martin Schiller (mschiller@tdt.de) wrote:
> On Thursday, October 12, 2006 10:38 AM, Eric Dumazet wrote:
> >
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
> > 
> 
> So, when do you mean the user-space application should run this syscalls?
> After the call to listen()?
> 
> Another problem with this solution might be, that I don't want to block the
> listening socket with the processing of one request, because there could be
> a lot of simultaneous requests. 

You should break your decision into per state change transformations.
I think it is possible with either conntrack or netlink module Samir
Bellabes <sbellabes_mandriva.com> creates (Network Events Connector
subject) or even using syncookie algo changes.

But it will drastically change your server performance...

-- 
	Evgeniy Polyakov
