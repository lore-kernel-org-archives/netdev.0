From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 5/5 RFC] TCPCT part1e: initial SYN exchange
 with SYNACK data
Date: Tue, 10 Nov 2009 10:45:50 -0500
Message-ID: <4AF98AAE.6000307@gmail.com>
References: <4AF83E2D.1050401@gmail.com> <4AF84BF3.5020302@gmail.com> <4AF978D3.7030207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	=?UTF-8?B?SWxwbyBKw6RydmluZW4=?= <ilpo.jarvinen@helsinki.fi>,
	Joe Perches <joe@perches.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f227.google.com ([209.85.218.227]:56424 "EHLO
	mail-bw0-f227.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756664AbZKJPpv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 10:45:51 -0500
Received: by bwz27 with SMTP id 27so147821bwz.21
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 07:45:56 -0800 (PST)
In-Reply-To: <4AF978D3.7030207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> William Allen Simpson a =C3=A9crit :
>> This is a significantly revised implementation of an earlier (year-o=
ld)
>> patch that no longer applies cleanly, with permission of the origina=
l
>> author (Adam Langley).  That patch was previously reviewed:
>>
>>    http://thread.gmane.org/gmane.linux.network/102586

> I really tried hard to understand what was going on, and failed, beca=
use I dont
> have much time these days...
>=20
Thanks very much for your time.

As I just wrote in a previous message, this is the easy part.  It's goi=
ng
to get much more complicated -- as you know, since I sent you the paper=
s
with 30+ references....


> Lack of documentation maybe ? Some DATA flow could help...
>=20
Where should that be?  In the commit messages?


> Please please, cook up elementatry patches to perform one action at a=
 time,
> even if they are not fully functionnal ?
>=20
Well, that's what I did with the (now) parts 1b, 1c, and 1d, but somebo=
dy
complained that the callers didn't exist yet.


> One patch to be able to send SYN + COOKIE (if we are the client)
>=20
> One patch to be able to receive this SYN + COOKIE and answer a SYNACK=
 + cookies (we are the server)
>=20
I'll split them.  Remember, I started with a code base previously
submitted, and everything was in one *single* large patch.  I thought
that's what you (Linux folks in general) wanted.


> One patch to ... Receive the ACK from client (if we are the server) a=
nd check cookies
>=20
> One patch to ...  Send the ACK (if we are the client)
>=20
> Patches to receive FIN + cookies
>=20
Maybe that's what you are missing, and why you're have difficulty
wrapping your mind around it.  None of that is there yet!

Receive the Ack options from the client is currently part 2.  I've also
lately divided part 2 into 4 sub-patches, although it all has to be
committed at one time:
   2a) extending the TCP option space,
   2b) receiving 64-bit timestamps,
   2c) receiving extended SACKs,
   2d) receiving the cookie pair.
Perhaps that could be split even further, although the order has to
stay the same.  A lot is written, although I gave up updating regularly
as the part 1 process has taken so long....

Send the Ack is currently part 3.

Handling FIN is currently part 4, although it might be split, too.

Handling RST is probably part 5.

Handling transactions was part 4 or 5, but could be a future part 6
instead (although it's rather tied up with both 4 and 5).


> One patch to ... enable the whole thing and setsockopt() bits
>=20
Ummm, then there'd be no way to test.  This is TCP we're talking about.
It has to be tested extensively.  This stuff needs to work.  I need the
bits to initiate all the tests....

That's why I like to get all my data structures nailed down first, and
then incrementally add code and test.
