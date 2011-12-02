From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Fri, 02 Dec 2011 12:57:51 +0100
Message-ID: <1322827071.2607.17.camel@edumazet-laptop>
References: <20111129.124715.163094087536706067.davem@davemloft.net>
	 <CA+mtBx_-_4zzweT61vYKe-c8ngMO9jF5PoYa4gC1aNKREjbwgQ@mail.gmail.com>
	 <20111201165018.GA19451@tugrik.mns.mnsspb.ru>
	 <20111201.130045.2061330448127491799.davem@davemloft.net>
	 <20111202112228.GB3433@tugrik.mns.mnsspb.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Kirill Smelkov <kirr@mns.spb.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:35163 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753915Ab1LBL5z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2011 06:57:55 -0500
Received: by vcbfk14 with SMTP id fk14so2249722vcb.19
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2011 03:57:55 -0800 (PST)
In-Reply-To: <20111202112228.GB3433@tugrik.mns.mnsspb.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 02 d=C3=A9cembre 2011 =C3=A0 15:22 +0400, Kirill Smelkov a =
=C3=A9crit :
> On Thu, Dec 01, 2011 at 01:00:45PM -0500, David Miller wrote:
> > From: Kirill Smelkov <kirr@mns.spb.ru>
> > Date: Thu, 1 Dec 2011 20:50:18 +0400
> >=20
> > > One "regression" is it is now not possible to disable BQL at comp=
ile time,
> > > because CONFIG_BQL can't be set to "n" via usual ways.
> > >=20
> > > Description and patch below. Thanks.
> >=20
> > It's intentional, and your patch will not be applied.
> >=20
> > The Kconfig entry and option is merely for expressing internal depe=
ndencies,
> > not for providing a way to disable the code.
>=20
> I'm maybe wrong somewhere - sorry then, but why there is e.g.
>=20
>      static inline void netdev_tx_sent_queue(struct netdev_queue *dev=
_queue,
>                                             unsigned int bytes)
>      {
>     +#ifdef CONFIG_BQL
>     +       dql_queued(&dev_queue->dql, bytes);
>     +       if (unlikely(dql_avail(&dev_queue->dql) < 0)) {
>     +               set_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->sta=
te);
>     +               if (unlikely(dql_avail(&dev_queue->dql) >=3D 0))
>     +                       clear_bit(__QUEUE_STATE_STACK_XOFF,
>     +                           &dev_queue->state);
>     +       }
>     +#endif
>      }
>=20
>=20
> and that netdev_tx_sent_queue() is called on every xmit.
>=20
> I wanted to save cycles on my small/slow hardware and compile BQL out=
 in
> case I know the system is not going to use it. I'm netdev newcomer, s=
o
> sorry if I ask naive questions, but what's wrong it?
>=20

Its something like 4 or 5 instructions (granted your NIC is BQL
enabled). Really nothing compared to thousand of instructions per packe=
t
spent in the stack and driver.

And BQL will benefit especially on your small/slow hardware, even if yo=
u
dont believe so or know yet.

BQL is probably the major new netdev functionality of the year.

Of course, you are free to patch your own kernel if you desperatly need
to save a few cycles per packet.
