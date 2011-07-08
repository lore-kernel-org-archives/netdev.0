From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: trying to set skb->tstamp before netif_rx did not work in
 tun/tap driver, 2.6.27
Date: Fri, 08 Jul 2011 07:45:00 +0200
Message-ID: <1310103900.2517.2.camel@edumazet-laptop>
References: <loom.20110708T042440-631@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Bill F <falcigno@juno.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33701 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751165Ab1GHFpF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2011 01:45:05 -0400
Received: by wyg8 with SMTP id 8so1073510wyg.19
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 22:45:04 -0700 (PDT)
In-Reply-To: <loom.20110708T042440-631@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 08 juillet 2011 =C3=A0 02:33 +0000, Bill F a =C3=A9crit :
> Hi all,
> =20
> I am trying to set the receive timestamp for a packet in the tun/tap =
device
> driver before sending it into the network stack (by calling netif_rx_=
ni). On the=20
> application side I'm using recvmsg() to receive the timestamp along w=
ith the=20
> received packet.
> =20
> I expected that any non-zero skb->tstamp I set would be the value my=20
> application would see when it used recvmsg(), but a corrupted value i=
s=20
> coming out.
> * If I hardcode skb->tstamp.tv64 to x7777777766666666=20
>         then recvmsg() always gets x011afd371a82fcc0.
> * If I hardcode x4de684b100000000,=20
>         then recvmsg always gets x4f5f96640f2d1608.
> * If I set a timestamp that a different process gave to the tun/tap d=
river
>         (this is the goal), then recvmsg gets a corrupted version of =
that=20
>         timestamp.
> * If I hardcode a zero tstamp,=20
>         then an accurate timestamp comes out (but not precise enough =
for my=20
>         project).
> =20
> The kernel build is 2.6.27.7, the architecture is MIPS, 64bit. Should=
n't this=20
> work? Do I need to apply any known patches?
> =20
> This arrangement worked last month in a similar setup: an e1000 drive=
r=20
> setting tstamp before calling netif_receive_skb() in a 2.6.24 kernel =
and a=20
> 686 architecture, 32 bit.
> =20

You probably are hardcoding too much things ;)

The only portable tv64 value is the zero one.

Check CONFIG_KTIME_SCALAR on your config, and ktime_set()
implementations in include/linux/ktime.h



