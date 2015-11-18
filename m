From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 07:16:00 -0800
Message-ID: <1447859760.22599.149.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
	 <20151117192738.365145d7@samsung9>
	 <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
	 <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
	 <1447845552.846962.443112033.03C5152B@webmail.messagingengine.com>
	 <CAKD1Yr1URnEWDpF9JUo_K3w+31YjfrO6tzL6QBcrKmSYu1_fhA@mail.gmail.com>
	 <1447853515.875338.443199993.7D592088@webmail.messagingengine.com>
	 <CAKD1Yr3jDozbnZsJy80uPFYAcqv+0ai0EN64i+jKorMe3-ggFA@mail.gmail.com>
	 <1447858590.895715.443293345.0FE778BF@webmail.messagingengine.com>
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
Received: from mail-pa0-f52.google.com ([209.85.220.52]:35380 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755148AbbKRPQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 10:16:04 -0500
Received: by pacej9 with SMTP id ej9so47671577pac.2
        for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 07:16:04 -0800 (PST)
In-Reply-To: <1447858590.895715.443293345.0FE778BF@webmail.messagingengine.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-18 at 15:56 +0100, Hannes Frederic Sowa wrote:
> On Wed, Nov 18, 2015, at 15:45, Lorenzo Colitti wrote:
> > On Wed, Nov 18, 2015 at 10:31 PM, Hannes Frederic Sowa
> > <hannes@stressinduktion.org> wrote:
> > > I was not saying using tcp_close literally, sorry for not making that
> > > clear, but just model the state transitions after tcp_close. At least it
> > > seems like a normal close to me.
> > 
> > But it shouldn't be a normal close. Consider calling SOCK_DESTROY on a
> > socket that is streaming data to a peer. If SOCK_DESTROY results in
> > the kernel sending a FIN, the remote side might think that the sender
> > closed the connection gracefully, even though the local side aborted
> > the connection.
> 
> Oh, yes, I understand. The connection wasn't closed by the application
> but by the administrator forcefully. So we should never indicate a
> successful TCP shutdown with FIN but with RST. A TIME_WAIT period
> actuallty still seems useful to me, maybe with different semantics, only
> RST incoming data?

There is some confusion.

TIME_WAIT are used to be able to send ACK packets to incoming valid
packets.

To send RST, you need nothing at all.

TIME_WAIT are hints for normal ending connections, to handle old packets
(and or duplicates)
