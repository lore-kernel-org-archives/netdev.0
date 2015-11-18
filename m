From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 12:19:12 +0100
Message-ID: <1447845552.846962.443112033.03C5152B@webmail.messagingengine.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
 <20151117192738.365145d7@samsung9>
 <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
 <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	Erik Kline <ek@google.com>,
	=?UTF-8?Q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	Dmitry Torokhov <dtor@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:33953 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755582AbbKRLTN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 06:19:13 -0500
Received: from compute4.internal (compute4.nyi.internal [10.202.2.44])
	by mailout.nyi.internal (Postfix) with ESMTP id B18FE20994
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 06:19:12 -0500 (EST)
In-Reply-To: <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015, at 11:47, Lorenzo Colitti wrote:
> On Wed, Nov 18, 2015 at 7:19 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > I bet there will soon be a timewaitd which handles the not configurable
> > (David has rejected all those patches so far) timeout of TIME_WAIT
> > sockets. And I bet it will be used. :/
> 
> No, SOCK_DESTROY has no effect on TCP_TIME_WAIT sockets or any other
> non-full socket.
> 
> When called on any socket where sk_fullsock(sk) is false, it returns
> EOPNOTSUPP because there is nothing to do. Its purpose is to interrupt
> blocked userspace socket calls, not to release resources.

Okay, thanks for clarification! Still I don't see how you enter
TIME_WAIT in case you kill an active socket. At least my start-up idea
timewaitd seems to be not implementable. ;)

I was wondering why you didn't use tcp_close function, because still we
could have the address and we would like to do a proper shutdown of the
connection. While this patchset wants to tear down sockets for addresses
no longer alive, it still can be used with full sockets.

Thanks,
Hannes
