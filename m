From: Josh Boyer <jwboyer@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at 000000000000002c
Date: Thu, 1 Dec 2011 15:37:01 -0500
Message-ID: <CA+5PVA6kZkgYus4698Up8Q8uMTetCU2=DnTD0RpgXuHkJj6KKg@mail.gmail.com>
References: <4ED7C367.3070109@profihost.ag>
	<20111201182309.GA10686@infradead.org>
	<1322770844.2750.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Christoph Hellwig <hch@infradead.org>,
	Stefan Priebe <s.priebe@profihost.ag>, netdev@vger.kernel.org,
	Dave Chinner <david@fromorbit.com>, stable@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35937 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753212Ab1LAUhC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2011 15:37:02 -0500
In-Reply-To: <1322770844.2750.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 1, 2011 at 3:20 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Le jeudi 01 d=E9cembre 2011 =E0 13:23 -0500, Christoph Hellwig a =E9c=
rit :
>> On Thu, Dec 01, 2011 at 07:11:51PM +0100, Stefan Priebe wrote:
>> > Hi,
>> >
>> > i'm not quite sure if this is an XFS thing or a tcp thing. As the
>> > stacktrace confuses me a little but as it contains
>> > xfs_bmap_search_extents and xfs_iunlock. Kernel is 3.0.11 running =
as
>> > 2.6.40.11.
>> >
>> > [171464.091567] BUG: unable to handle kernel NULL pointer
>> > dereference at 000000000000002c
>> > [171464.092073] IP: [<ffffffff815494f6>] ipv4_dst_check+0xb6/0x190
>> > [171464.092073] PGD 15344e067 PUD 14c821067 PMD 0
>> > [171464.092073] Oops: 0002 [#1] SMP
>> >
>> > Full Stacktrace:
>> > http://pastebin.com/raw.php?i=3DQNg6jD2t
>>
>> The ? entries mean even the backtrace code things they are unreliabl=
e,
>> and mos of the cases I've seen they are wrong. =A0In this case it lo=
oks
>> like the process was doing XFS work before, but the current system c=
all
>> indeed is purely in the networking code.
>>
>> I've changed the cc list to the netdev list which is more appropinqu=
ate.
>
> Probably fixed by commit 81d54ec8479a2c695760da
> (net: fix NULL dereferences in check_peer_redir())

Did you mean f2c31e32b378a665 ?  81d54ec84 is:

udp: remove redundant variable

in Linus' tree.

> But this patch needs some followup patches (some of them in David net
> tree, not yet in Linus tree)

9de79c127cccecb11ae6a21ab1499e87aa222880 (net: fix potential neighbour
race in dst_ifdown()) is in Linus' tree.  Which others are missing?

josh
