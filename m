From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCHv7 1/5] Remove unnecessary locks from rtnetlink (in do_setlink)
Date: Mon, 03 Dec 2007 12:59:31 +0100
Message-ID: <4753EFA3.9020309@balabit.hu>
References: <11963527094077-git-send-email-panther@balabit.hu> <11963527103201-git-send-email-panther@balabit.hu> <47508AF0.7070204@o2.pl>
Reply-To: panther@balabit.hu
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:44021 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754496AbXLCL7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 06:59:35 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id AF4F3C137F
	for <netdev@vger.kernel.org>; Mon,  3 Dec 2007 12:59:33 +0100 (CET)
In-Reply-To: <47508AF0.7070204@o2.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski =EDrta:
> Laszlo Attila Toth wrote, On 11/29/2007 05:11 PM:
>=20
>> The do_setlink function is protected by rtnl, additional locks are u=
nnecessary,
>> and the set_operstate() function is called from protected parts. Loc=
ks removed
>> from both functions.
>=20
> It doesn't look like in accordance with a comment to dev_base_lock in=
 dev.c.
> And it makes eg. rfc2863_policy() locking from link_watch.c looking s=
trange.
> Isn't there needed some additional comment to this?

I modified do_setlink(), but set_operstate() is also called from
rtnl_create_link() and from no other places.  In rtnl_create_link() non=
e=20
of the changes is protected by set_lock_bh() except inside=20
set_operstate(), different locking scheme is not necessary for the=20
operstate.

Also two solution can be made, one is locking everything and one is=20
locking nothing (to unify the changes made by these parts). The second=20
one is better if it is protected.

I tried to figure out how it is protected but I couldn't. But Patrick=20
said it is protected by rtnl. And he suggested this patch.


Attila
