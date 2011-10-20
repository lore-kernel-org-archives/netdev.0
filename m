From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [PATCH] net: change capability used by socket options IP{,V6}_TRANSPARENT
Date: Wed, 19 Oct 2011 21:31:06 -0700
Message-ID: <CAHo-OoxYiqSOg6fPWWAaocF2L3DzyV_UFYT0CPRGVd7LNxDCwg@mail.gmail.com>
References: <1318889783-23183-1-git-send-email-zenczykowski@gmail.com>
	<20111019.193435.1214580639401316303.davem@davemloft.net>
	<CANP3RGf1ZyNEiADXMsD1C=4GMyOMvxEZQ93nYpghhXhCJKNF6Q@mail.gmail.com>
	<20111020.001939.548341110762997206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, bazsi@balabit.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:57143 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750978Ab1JTEbH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 00:31:07 -0400
Received: by yxp4 with SMTP id 4so2421713yxp.19
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2011 21:31:06 -0700 (PDT)
In-Reply-To: <20111020.001939.548341110762997206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I don't see any real benefit.
>
> If it has been decided that you can't create a new capability for
> tproxy, so that tasks can be segregated out of these more powerful
> networking capability levels, I simply don't see the point.

It indeed seems that transparent may be a little too specific a capability.
Ultimately linux permissions are just not fine grained enough...
unless you start using LSMs

> A process with CAP_NET_RAW can spit whatever crap they want onto the
> network, and receive all packets with impunity.

Agreed.  But it can do so via raw sockets, it cannot do so via normal
udp/tcp/ip sockets.
That's why I'd like to relax the permissions check on being able to
switch a socket
into transparent mode.  A process with CAP_NET_RAW can already pretty
much emulate
that behaviour by using raw sockets - it just can't do that using the
higher level, often more
usable/useful socket/protocol apis.

> I can't see what this buys us at all, sorry.

See above.
