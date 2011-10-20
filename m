From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: Comment on nf_queue NF_STOLEN patch
Date: Thu, 20 Oct 2011 12:30:15 +0200
Message-ID: <20111020103015.GB20625@1984>
References: <4E988B1E.5000606@itcare.pl>
 <CAEuXFEy89F_=J_PJMSbQ1fDcOEkkpz2vucq3LcToi7rTcZHcDA@mail.gmail.com>
 <4E9DCEAD.7070603@verizon.net>
 <1318973032.19139.5.camel@edumazet-laptop>
 <4E9DF0EB.8080008@verizon.net>
 <1318997435.19139.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jim Sansing <jjsansing@verizon.net>,
	Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, Florian Westphal <fw@strlen.de>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1318997435.19139.16.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 19, 2011 at 06:10:35AM +0200, Eric Dumazet wrote:
> Le mardi 18 octobre 2011 =E0 17:34 -0400, Jim Sansing a =E9crit :
> > Eric Dumazet wrote:
> > > Le mardi 18 octobre 2011 =E0 15:08 -0400, Jim Sansing a =E9crit :
> > >  =20
> > >> I have been working on a kernel module that registers with netfi=
lter,
> > >> and I noticed that a patch was added to nf_queue that changed th=
e
> > >> handling of return code NF_FILTER from 'do nothing' to 'free the=
 skb'.=20
> > >> I'm not sure which kernel version this went in, but the date of =
the
> > >> patch is Feb, 19, 2010.
> > >>
> > >> Everything I have read about netfilter states that it is up to t=
he
> > >> netfilter hook to free the skb if NF_STOLEN is returned.  The
> > >> implications of this patch from a hook programming perspective a=
re:
> > >>
> > >> 1) If the skb is used after the return from the hook, it must be=
 cloned.
> > >> 2) The original skb must not be freed.
> > >>
> > >> I suggest that a comment be added to include/linux/netfilter.h t=
hat says
> > >> explicitly the skb will be freed if NF_STOLEN is returned.
> > >>    =20
> > >
> > > But its not true. Just read the code.
> > >
> > > If you are working on this stuff I recommend you take a look at
> > > commits :
> > >
> > > c6675233f9015d3c0460c8aab53ed9b99d915c64
> > > (netfilter: nf_queue: reject NF_STOLEN verdicts from userspace)
> > >
> > > fad54440438a7c231a6ae347738423cbabc936d9
> > > (netfilter: avoid double free in nf_reinject)
> > >
> > > 64507fdbc29c3a622180378210ecea8659b14e40
> > > (netfilter: nf_queue: fix NF_STOLEN skb leak)
> > >
> > > 3bc38712e3a6e0596ccb6f8299043a826f983701
> > > ([NETFILTER]: nf_queue: handle NF_STOP and unknown verdicts in
> > > nf_reinject)
> > >
> > >  =20
> >=20
> > I see that fad54440438a7c231a6ae347738423cbabc936d9 (netfilter: avo=
id
> > double free in nf_reinject) returns the switch case for NF_STOLEN b=
ack
> > to the original state, but I just downloaded 3.0.4, and the skb is =
still
> > freed.  So for some versions of the kernel, the situation exists.=20
> > Hopefully anyone who runs into it will find this thread.
> >=20
>=20
> Hopefully netfilter guys (CCed) will sort out the problem and ask sta=
ble
> submissions, if not already done. 3.0.4 is quite old :)

Not done yet, sorry. I'll do it asap.
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
