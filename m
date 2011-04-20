From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipqueue allocation failure.
Date: Wed, 20 Apr 2011 07:27:47 +0200
Message-ID: <1303277267.2756.14.camel@edumazet-laptop>
References: <20110420014221.GC26949@redhat.com>
	 <20110419.204105.68144653.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davej@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39368 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543Ab1DTF1y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 01:27:54 -0400
Received: by wya21 with SMTP id 21so299200wya.19
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2011 22:27:53 -0700 (PDT)
In-Reply-To: <20110419.204105.68144653.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 19 avril 2011 =C3=A0 20:41 -0700, David Miller a =C3=A9crit :
> From: Dave Jones <davej@redhat.com>
> Date: Tue, 19 Apr 2011 21:42:22 -0400
>=20
> > Not catastrophic, but ipqueue seems to be too trusting of what it g=
ets
> > passed from userspace, and passes it on down to the page allocator,
> > where it will spew warnings if the page order is too high.
> >=20
> > __ipq_rcv_skb has several checks for lengths too small, but doesn't
> > seem to have any for oversized ones.   I'm not sure what the maximu=
m
> > we should check for is. I'll code up a diff if anyone has any ideas
> > on a sane maximum.
>=20
> Maybe the thing to do is to simply pass __GFP_NOWARN to nlmsg_new()
> in netlink_ack()?
>=20
> Anyone else have a better idea?
> --

It should be fine, since we already checked sk->sk_sndbuf in
netlink_sendmsg()

if (len > sk->sk_sndbuf - 32)
	goto out;

Maybe the 32 magic value is too small to take into account
struct nlmsgerr that is prepended in netlink_ack()

Hmm, no, sizeof(struct nlmsgerr) is 20



