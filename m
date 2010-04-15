From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: using smp_processor_id() in preemptible [00000000] code:
 avahi-daemon: caller is netif_rx
Date: Thu, 15 Apr 2010 12:29:02 +0200
Message-ID: <1271327342.16881.2355.camel@edumazet-laptop>
References: <20100415.003711.159334670.davem@davemloft.net>
	 <u2o412e6f7f1004150047nc9250ffuaef68be066a7575c@mail.gmail.com>
	 <1271321358.16881.2240.camel@edumazet-laptop>
	 <20100415.020246.218622820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: xiaosuo@gmail.com, therbert@google.com, eparis@redhat.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f225.google.com ([209.85.218.225]:60668 "EHLO
	mail-bw0-f225.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752863Ab0DOK3N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 06:29:13 -0400
Received: by bwz25 with SMTP id 25so1342038bwz.28
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 03:29:11 -0700 (PDT)
In-Reply-To: <20100415.020246.218622820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 15 avril 2010 =C3=A0 02:02 -0700, David Miller a =C3=A9crit :

> Since we keep coming back to this issue why don't we simply
> solve it forever?  Let's make netif_rx() work in all contexts
> and get rid of netif_rx_ni().
>=20
> I think this is the thing to do because this whole netif_rx_ni()
> vs. netif_rx() thing was meant to be an optimization of sorts (this
> goes back to like 8+ years ago :-), and really I doubt it really
> matters on that level any more.
>=20
> What do you think?

I was about to come to same idea indeed.

netif_receive_skb() is supposed to be used for modern devices anyway,
avoiding netif_rx() overhead...




