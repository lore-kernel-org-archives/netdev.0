From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netfilter: don't disable BH again in BH disabled
 context
Date: Wed, 22 Sep 2010 15:22:27 +0200
Message-ID: <1285161747.2639.413.camel@edumazet-laptop>
References: <1282027297-9998-1-git-send-email-xiaosuo@gmail.com>
	 <1282028127.2487.754.camel@edumazet-laptop>
	 <AANLkTi=r23zwZpO=Y++a608=K6f7-FvcL2d-gY+foggm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=r23zwZpO=Y++a608=K6f7-FvcL2d-gY+foggm@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 22 septembre 2010 =C3=A0 18:20 +0800, Changli Gao a =C3=A9c=
rit :
> On Tue, Aug 17, 2010 at 2:55 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
> >
> > Its a thing that might change in a future version. Not a hard fact.
> >
> > You can probably change iptables to allow softirqs while processing
> > OUTPUT chains.
> >
> > We had some attempts in the past to switch to RCU.
> >
> > It failed at that time because of some RCU implementation details, =
but
> > with recent RCU changes, we might try again, and have a clean
> > implementation, allowing softirqs.
> >
> > So your patch would need to be reverted.
> >
>=20
> So the smp_processor_id() in xt_cpu.c should be replaced with
> raw_smp_processor_id()?
>=20

Using smp_processor_id() is better. This provides automatic checking.

If we change output processing to allow softirqs, that doesnt mean we
allow preemption or cpu migration :)



--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
