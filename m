From: Kirill Smelkov <kirr@mns.spb.ru>
Subject: Re: [PATCH v4 0/10] bql: Byte Queue Limits
Date: Fri, 2 Dec 2011 16:26:56 +0400
Message-ID: <20111202122656.GA25427@tugrik.mns.mnsspb.ru>
References: <20111129.124715.163094087536706067.davem@davemloft.net> <CA+mtBx_-_4zzweT61vYKe-c8ngMO9jF5PoYa4gC1aNKREjbwgQ@mail.gmail.com> <20111201165018.GA19451@tugrik.mns.mnsspb.ru> <20111201.130045.2061330448127491799.davem@davemloft.net> <20111202112228.GB3433@tugrik.mns.mnsspb.ru> <1322827071.2607.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mnsspb.ru ([84.204.75.2]:51574 "EHLO mail.mnsspb.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754982Ab1LBM3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Dec 2011 07:29:04 -0500
Content-Disposition: inline
In-Reply-To: <1322827071.2607.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 02, 2011 at 12:57:51PM +0100, Eric Dumazet wrote:
> Le vendredi 02 d=E9cembre 2011 =E0 15:22 +0400, Kirill Smelkov a =E9c=
rit :
> > On Thu, Dec 01, 2011 at 01:00:45PM -0500, David Miller wrote:
> > > From: Kirill Smelkov <kirr@mns.spb.ru>
> > > Date: Thu, 1 Dec 2011 20:50:18 +0400
> > >=20
> > > > One "regression" is it is now not possible to disable BQL at co=
mpile time,
> > > > because CONFIG_BQL can't be set to "n" via usual ways.
> > > >=20
> > > > Description and patch below. Thanks.
> > >=20
> > > It's intentional, and your patch will not be applied.
> > >=20
> > > The Kconfig entry and option is merely for expressing internal de=
pendencies,
> > > not for providing a way to disable the code.
> >=20
> > I'm maybe wrong somewhere - sorry then, but why there is e.g.
> >=20
> >      static inline void netdev_tx_sent_queue(struct netdev_queue *d=
ev_queue,
> >                                             unsigned int bytes)
> >      {
> >     +#ifdef CONFIG_BQL
> >     +       dql_queued(&dev_queue->dql, bytes);
> >     +       if (unlikely(dql_avail(&dev_queue->dql) < 0)) {
> >     +               set_bit(__QUEUE_STATE_STACK_XOFF, &dev_queue->s=
tate);
> >     +               if (unlikely(dql_avail(&dev_queue->dql) >=3D 0)=
)
> >     +                       clear_bit(__QUEUE_STATE_STACK_XOFF,
> >     +                           &dev_queue->state);
> >     +       }
> >     +#endif
> >      }
> >=20
> >=20
> > and that netdev_tx_sent_queue() is called on every xmit.
> >=20
> > I wanted to save cycles on my small/slow hardware and compile BQL o=
ut in
> > case I know the system is not going to use it. I'm netdev newcomer,=
 so
> > sorry if I ask naive questions, but what's wrong it?
> >=20
>=20
> Its something like 4 or 5 instructions (granted your NIC is BQL
> enabled). Really nothing compared to thousand of instructions per pac=
ket
> spent in the stack and driver.
>=20
> And BQL will benefit especially on your small/slow hardware, even if =
you
> dont believe so or know yet.
>=20
> BQL is probably the major new netdev functionality of the year.
>=20
> Of course, you are free to patch your own kernel if you desperatly ne=
ed
> to save a few cycles per packet.

Thanks for describing this Eric. I'll try BQL and see how it goes as yo=
u
suggest. Please note that the confusion here could be avoided if there
was a tiny bit of documentation.


Thanks again,
Kirill
