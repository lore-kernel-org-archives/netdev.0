From: Sebastian =?ISO-8859-1?Q?P=F6hn?= <sebastian.poehn@gmail.com>
Subject: Re: nf_conntrack_h323: Fix locking in process_urq
Date: Fri, 15 Jan 2016 23:57:12 +0100
Message-ID: <1452898632.3162.0.camel@gmail.com>
References: <1452894918.4622.3.camel@gmail.com>
	 <20160115224233.GA20767@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20160115224233.GA20767@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

You are right. The problem is fixed since 3.15 with the expect_lock ref=
actoring.
We found this in 3.12. Probably this is something for stable releases 3=
=2E14 and earlier.

Am 15.01.2016 11:42 nachm. schrieb "Florian Westphal" <fw@strlen.de>:
>
> Sebastian P=C3=B6hn <sebastian.poehn@gmail.com> wrote:
>
> [ CC netfilter-devel ]
>
> > nf_ct_remove_expectations has to be called under nf_conntrack_expec=
t_lock
>
> But nf_ct_remove_expectations grabs that lock?
>
> Added in:
>
> commit ca7433df3a672efc88e08222cfa4b3aa965ca324
> Author: Jesper Dangaard Brouer <brouer@redhat.com>
> netfilter: conntrack: seperate expect locking from nf_conntrack_lock
>
> > diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter=
/nf_conntrack_h323_main.c
> > index 9511af0..d477375 100644
> > --- a/net/netfilter/nf_conntrack_h323_main.c
> > +++ b/net/netfilter/nf_conntrack_h323_main.c
> > @@ -1518,7 +1518,9 @@ static int process_urq(struct sk_buff *skb, s=
truct nf_conn *ct,
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0}
> > =C2=A0
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0/* Clear old expect=
 */
> > +=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0spin_lock_bh(&nf_conntra=
ck_expect_lock);
> > =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0nf_ct_remove_expect=
ations(ct);
>
> ... so I'd expect deadlock.
>
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
