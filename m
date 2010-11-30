From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Tue, 30 Nov 2010 06:42:16 +0100
Message-ID: <1291095736.2725.5.camel@edumazet-laptop>
References: <AANLkTimwo_ok=1dfzOST=rKqQdNS95wUAVdrrZHBMddS@mail.gmail.com>
	 <20101129.191457.193722052.davem@davemloft.net>
	 <AANLkTin11AYaFWMArC6fNQnvej2+=WUfOtTVrtX8WLEZ@mail.gmail.com>
	 <20101129.212222.115953137.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64222 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab0K3FmW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 00:42:22 -0500
Received: by wwa36 with SMTP id 36so5652029wwa.1
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 21:42:20 -0800 (PST)
In-Reply-To: <20101129.212222.115953137.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 29 novembre 2010 =C3=A0 21:22 -0800, David Miller a =C3=A9crit=
 :
> From: Changli Gao <xiaosuo@gmail.com>
> Date: Tue, 30 Nov 2010 12:51:08 +0800
>=20
> > On Tue, Nov 30, 2010 at 11:14 AM, David Miller <davem@davemloft.net=
> wrote:
> >> From: Changli Gao <xiaosuo@gmail.com>
> >> Date: Tue, 30 Nov 2010 10:33:49 +0800
> >>
> >>> I have thought about converting this AVL tree to rbtree. When I s=
aw
> >>> the comment above, I gave it up, because rbtree makes this struct=
ure
> >>> bigger. If ipv6 support is added, I think it is time to turn to
> >>> rbtree. :)
> >>
> >> If it takes size over 128 bytes, it is probably still a bad idea.
> >> Right now it is just under 128.
> >>
> >=20
> > Why 128? The current size of inet_peer is 64 bytes, and after your
> > ipv6 patch, it is just 80. And, inet_peer is allocated from its own
> > mem_cache, so the size of the memory for it should not be aligned t=
o
> > 2^n.
>=20
> Sorry, I was taking into the consideration other work I am doing
> which will move all of the routing metrics into inet_peer as well.
>=20
> With ipv6 address support, it fits perfectly into 128 bytes on
> 64-bit.
> --

Its a bit early in the morning here, I must confess I dont yet
understand your patch David :)

As we use a tree, why not using two different trees for ipv4 / ipv6 ?

I dont understand how computing a 32bit key (sort of hash key) is going
to help when hash collision happens, with an avl tree.


=46or Changli : AVL tree was OK for RCU conversion, I am not sure about
RBtree yet.

Either version of tree (AVL/rbtree) will be expensive to use if depth i=
s
big (With 2 millions entries, depth is going to be very big). I
understand you want to get rid of route cache ?



