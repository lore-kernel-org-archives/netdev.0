From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 04:54:00 -0800
Message-ID: <1447851240.22599.147.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
	 <20151117192738.365145d7@samsung9>
	 <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
	 <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
	 <1447845552.846962.443112033.03C5152B@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Lorenzo Colitti <lorenzo@google.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Erik Kline <ek@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35750 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751513AbbKRMyE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 07:54:04 -0500
Received: by pacej9 with SMTP id ej9so44457647pac.2
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 04:54:02 -0800 (PST)
In-Reply-To: <1447845552.846962.443112033.03C5152B@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-18 at 12:19 +0100, Hannes Frederic Sowa wrote:
> On Wed, Nov 18, 2015, at 11:47, Lorenzo Colitti wrote:
> > On Wed, Nov 18, 2015 at 7:19 PM, Hannes Frederic Sowa
> > <hannes@stressinduktion.org> wrote:
> > > I bet there will soon be a timewaitd which handles the not configurable
> > > (David has rejected all those patches so far) timeout of TIME_WAIT
> > > sockets. And I bet it will be used. :/
> > 
> > No, SOCK_DESTROY has no effect on TCP_TIME_WAIT sockets or any other
> > non-full socket.
> > 
> > When called on any socket where sk_fullsock(sk) is false, it returns
> > EOPNOTSUPP because there is nothing to do. Its purpose is to interrupt
> > blocked userspace socket calls, not to release resources.
> 
> Okay, thanks for clarification! Still I don't see how you enter
> TIME_WAIT in case you kill an active socket. At least my start-up idea
> timewaitd seems to be not implementable. ;)
> 
> I was wondering why you didn't use tcp_close function, because still we
> could have the address and we would like to do a proper shutdown of the
> connection. While this patchset wants to tear down sockets for addresses
> no longer alive, it still can be used with full sockets.

I guess this could work, but we would have to also propose a mechanism
where no FIN/RST message is sent.

This might be the time for upstreaming our TCP_SILENT_CLOSE
implementation.

/* on close(): free sock, no FIN/RST */

It seems there is a lot of confusion on this thread about these patches.

Proposal is _not_ changing TCP stack behavior, as David Laight seems to
fear.
