From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 08:09:50 -0700
Message-ID: <20081021080950.5285d5e4@extreme>
References: <20081020190922.7dd6510a@extreme>
	<48FD6E8A.6060304@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59936 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270AbYJUPJ6 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 11:09:58 -0400
In-Reply-To: <48FD6E8A.6060304@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 21 Oct 2008 07:54:18 +0200
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Stephen Hemminger a =C3=A9crit :
> > Add support for recycling tx buffers into receive buffers.
> > This is experimental at this point.
> >=20
>=20
> I really like this skb recycling
>=20
> For best performance, driver should perform TX completion before RX c=
ompletion, so that
> freshly added skb in recycle queue have a chance being reused right a=
fter. Apparently sky2
> tx handling is finegrained (events posted by NIC)

The NIC always reports TX completion after RX, so recycling doesn't wor=
k that well.

> But still, this mechanism also use more skbs per device, especially o=
n dormant ones.
>=20
> If your RX ring has 256 skb, then adding the recycle queue can adds 2=
56 more skbs... One MB or event more...
>=20
> Maybe we should flush the recycle queue, every 5 seconds or so, espec=
ially if device is dormant
> (no RX on it, litle heartbeat TX)

I think dropping the recycle queue down to the typical max number of re=
ceive frames per interrupt
which is between 4 and 16 would be enough.
