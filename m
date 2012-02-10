From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] datagram: Extend the datagram queue MSG_PEEK-ing
Date: Fri, 10 Feb 2012 15:41:42 +0100
Message-ID: <1328884902.2443.29.camel@edumazet-laptop>
References: <4F352182.6060601@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:41630 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986Ab2BJOlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2012 09:41:46 -0500
Received: by wics10 with SMTP id s10so2058118wic.19
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2012 06:41:45 -0800 (PST)
In-Reply-To: <4F352182.6060601@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 f=C3=A9vrier 2012 =C3=A0 17:54 +0400, Pavel Emelyanov a =
=C3=A9crit :
> We're working on the checkpoint-restore project. To checkpoint a unix=
 socket
> we need to read its skb queue. Analogous task for TCP sockets Tejun p=
roposed
> to solve with parasite + recvmsg + MSG_PEEK. That's nice, but doesn't=
 work
> for unix sockets, because for them MSG_PEEK always peeks a single skb=
 from the=20
> head of the queue.
>=20
> I propose to extend the MSG_PEEK functionality with two more flags th=
at peek
> either next not picked skb in queue or pick the last picked one. The =
latter
> ability is required to make it possible to re-read a message if MSG_T=
RUNC
> was reported on it.
>=20
> These two flags can be used for unix stream sockets, since making the=
 MSG_PEEK
> just report all data that fits the buffer length is bad -- we may hav=
e scms
> in queue thus turning stream socket into dgram one.
>=20
> Signed-off-by: Pavel Emelyanov <xemul@parallels.com>
>=20
> ---

Nice !

So this CR stuff assumes an application wont use itself MSG_PEEK /
MORE / AGAIN ?

(skb->peeked can only be set, never unset)
