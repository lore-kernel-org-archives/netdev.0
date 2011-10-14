From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] niu: fix skb truesize underestimation
Date: Fri, 14 Oct 2011 05:33:51 +0200
Message-ID: <1318563231.2533.55.camel@edumazet-laptop>
References: <1318545567.2533.46.camel@edumazet-laptop>
	 <20111013.222659.12182837968152363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f42.google.com ([74.125.82.42]:47256 "EHLO
	mail-ww0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754966Ab1JNDd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 23:33:57 -0400
Received: by wwn22 with SMTP id 22so196548wwn.1
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2011 20:33:56 -0700 (PDT)
In-Reply-To: <20111013.222659.12182837968152363.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 octobre 2011 =C3=A0 22:26 -0400, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 14 Oct 2011 00:39:27 +0200
>=20
> > Add a 'truesize' argument to niu_rx_skb_append(), filled with rcr_s=
ize
> > by the caller to properly account frag sizes in skb->truesize
> >=20
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> > ---
> > Please David double check this one as I am not very familiar with N=
IU
> > code. Thanks !
>=20
> It looks perfect!  And if it's not I'll soon find out :-)
>=20

Thanks !

By the way, I noticed NIU uses a get_page() every time a chunk is
attached to a skb (only the last chunk of a page is given without the
get_page())

So I thought it might incur false sharing if a previous SKB using a
chunk from same page is processed by another CPU.

But then I see you also do in niu_rbr_add_page(), rigth after the
alloc_page(), the thing I was thinking to add : (perform all needed
get_page() in a single shot)

atomic_add(rp->rbr_blocks_per_page - 1,
	&compound_head(page)->_count);

So I am a bit lost here. Arent you doing too many page->_count
increases ?

Thanks !
