From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Suppress / delay SYN-ACK
Date: Thu, 12 Oct 2006 12:39:30 +0200
Message-ID: <200610121239.30823.dada1@cosmosbay.com>
References: <200610121038.18309.dada1@cosmosbay.com> <000201c6ede7$0ef3e110$1a04010a@V505CP> <20061012103102.GA17891@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="koi8-r"
Content-Transfer-Encoding: 7bit
Cc: Martin Schiller <mschiller@tdt.de>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:35221 "EHLO pfx2.jmh.fr")
	by vger.kernel.org with ESMTP id S1751238AbWJLKj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2006 06:39:28 -0400
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
In-Reply-To: <20061012103102.GA17891@2ka.mipt.ru>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 October 2006 12:31, Evgeniy Polyakov wrote:
> On Thu, Oct 12, 2006 at 12:13:26PM +0200, Martin Schiller (mschiller@tdt.de) 
wrote:
> > On Thursday, October 12, 2006 10:38 AM, Eric Dumazet wrote:
> > > Well, it is already possible to delay the 'third packet' of an
> > > outgoing connection with a litle hack. But AFAIK not the SYNACK of
> > > incoming connection. It could be cool. Maybe some new syscalls are
> > > needed:
> > >
> > > int syn_recv(int socklisten, ...);
> > > /* give to user app the SYN packet */
> > > int syn_ack(int socklisten, ...);
> > > /* User app has the ability to ask kernel tcp stack to :
> > >     DROP this packet.
> > >     REJECT the attempt
> > >     ACCEPT the attempt (sending a SYN/ACK) */
> >
> > So, when do you mean the user-space application should run this syscalls?
> > After the call to listen()?
> >
> > Another problem with this solution might be, that I don't want to block
> > the listening socket with the processing of one request, because there
> > could be a lot of simultaneous requests.
>
> You should break your decision into per state change transformations.
> I think it is possible with either conntrack or netlink module Samir
> Bellabes <sbellabes_mandriva.com> creates (Network Events Connector
> subject) or even using syncookie algo changes.

Hum.. they are some cases where conntrack is not an option (way too expensive 
if your server handle XXX.XXX concurrent tcp streams)

>
> But it will drastically change your server performance...

Sure, at least its capacity to answer to SYN packets (session establishment 
should be slower, unless the thread receiving/handling SYN packets has 
realtime scheduling)

Eric
