From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Add a SOCK_DESTROY operation to close sockets from userspace
Date: Wed, 18 Nov 2015 15:56:30 +0100
Message-ID: <1447858590.895715.443293345.0FE778BF@webmail.messagingengine.com>
References: <1447811024-8553-1-git-send-email-lorenzo@google.com>
 <20151117192738.365145d7@samsung9>
 <1447819493.22599.137.camel@edumazet-glaptop2.roam.corp.google.com>
 <1447841988.834928.443071345.1AAFF2A9@webmail.messagingengine.com>
 <CAKD1Yr0Gpr6Ex2i1TXEWyETn48P4g5vBvFZ9=_g+Lz_7-PqBDQ@mail.gmail.com>
 <1447845552.846962.443112033.03C5152B@webmail.messagingengine.com>
 <CAKD1Yr1URnEWDpF9JUo_K3w+31YjfrO6tzL6QBcrKmSYu1_fhA@mail.gmail.com>
 <1447853515.875338.443199993.7D592088@webmail.messagingengine.com>
 <CAKD1Yr3jDozbnZsJy80uPFYAcqv+0ai0EN64i+jKorMe3-ggFA@mail.gmail.com>
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
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:40131 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932798AbbKRO4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2015 09:56:31 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 0488E209EA
	for <netdev@vger.kernel.org>; Wed, 18 Nov 2015 09:56:30 -0500 (EST)
In-Reply-To: <CAKD1Yr3jDozbnZsJy80uPFYAcqv+0ai0EN64i+jKorMe3-ggFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 18, 2015, at 15:45, Lorenzo Colitti wrote:
> On Wed, Nov 18, 2015 at 10:31 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
> > I was not saying using tcp_close literally, sorry for not making that
> > clear, but just model the state transitions after tcp_close. At least it
> > seems like a normal close to me.
> 
> But it shouldn't be a normal close. Consider calling SOCK_DESTROY on a
> socket that is streaming data to a peer. If SOCK_DESTROY results in
> the kernel sending a FIN, the remote side might think that the sender
> closed the connection gracefully, even though the local side aborted
> the connection.

Oh, yes, I understand. The connection wasn't closed by the application
but by the administrator forcefully. So we should never indicate a
successful TCP shutdown with FIN but with RST. A TIME_WAIT period
actuallty still seems useful to me, maybe with different semantics, only
RST incoming data?

Bye,
Hannes
