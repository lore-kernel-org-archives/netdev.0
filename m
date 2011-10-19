From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Comment on nf_queue NF_STOLEN patch
Date: Wed, 19 Oct 2011 06:10:35 +0200
Message-ID: <1318997435.19139.16.camel@edumazet-laptop>
References: <4E988B1E.5000606@itcare.pl>
	 <CAEuXFEy89F_=J_PJMSbQ1fDcOEkkpz2vucq3LcToi7rTcZHcDA@mail.gmail.com>
	 <4E9DCEAD.7070603@verizon.net> <1318973032.19139.5.camel@edumazet-laptop>
	 <4E9DF0EB.8080008@verizon.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Network Development list <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, Florian Westphal <fw@strlen.de>
To: Jim Sansing <jjsansing@verizon.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <4E9DF0EB.8080008@verizon.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 18 octobre 2011 =C3=A0 17:34 -0400, Jim Sansing a =C3=A9crit :
> Eric Dumazet wrote:
> > Le mardi 18 octobre 2011 =C3=A0 15:08 -0400, Jim Sansing a =C3=A9cr=
it :
> >  =20
> >> I have been working on a kernel module that registers with netfilt=
er,
> >> and I noticed that a patch was added to nf_queue that changed the
> >> handling of return code NF_FILTER from 'do nothing' to 'free the s=
kb'.=20
> >> I'm not sure which kernel version this went in, but the date of th=
e
> >> patch is Feb, 19, 2010.
> >>
> >> Everything I have read about netfilter states that it is up to the
> >> netfilter hook to free the skb if NF_STOLEN is returned.  The
> >> implications of this patch from a hook programming perspective are=
:
> >>
> >> 1) If the skb is used after the return from the hook, it must be c=
loned.
> >> 2) The original skb must not be freed.
> >>
> >> I suggest that a comment be added to include/linux/netfilter.h tha=
t says
> >> explicitly the skb will be freed if NF_STOLEN is returned.
> >>    =20
> >
> > But its not true. Just read the code.
> >
> > If you are working on this stuff I recommend you take a look at
> > commits :
> >
> > c6675233f9015d3c0460c8aab53ed9b99d915c64
> > (netfilter: nf_queue: reject NF_STOLEN verdicts from userspace)
> >
> > fad54440438a7c231a6ae347738423cbabc936d9
> > (netfilter: avoid double free in nf_reinject)
> >
> > 64507fdbc29c3a622180378210ecea8659b14e40
> > (netfilter: nf_queue: fix NF_STOLEN skb leak)
> >
> > 3bc38712e3a6e0596ccb6f8299043a826f983701
> > ([NETFILTER]: nf_queue: handle NF_STOP and unknown verdicts in
> > nf_reinject)
> >
> >  =20
>=20
> I see that fad54440438a7c231a6ae347738423cbabc936d9 (netfilter: avoid
> double free in nf_reinject) returns the switch case for NF_STOLEN bac=
k
> to the original state, but I just downloaded 3.0.4, and the skb is st=
ill
> freed.  So for some versions of the kernel, the situation exists.=20
> Hopefully anyone who runs into it will find this thread.
>=20

Hopefully netfilter guys (CCed) will sort out the problem and ask stabl=
e
submissions, if not already done. 3.0.4 is quite old :)




--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
