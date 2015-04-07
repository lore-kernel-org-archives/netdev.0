From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Tue, 07 Apr 2015 17:58:30 +0200
Message-ID: <1428422310.2928.8.camel@stressinduktion.org>
References: <1427834148.979686.247747037.29964C1B@webmail.messagingengine.com>
	 <20150331.164923.229749666073516444.davem@davemloft.net>
	 <68621427882330@webcorp01g.yandex-team.ru>
	 <20150401.135532.1368728758929086692.davem@davemloft.net>
	 <1427916447.1816412.248215129.072B6ABF@webmail.messagingengine.com>
	 <36791427998117@webcorp02f.yandex-team.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Roman Gushchin <klamm@yandex-team.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <36791427998117@webcorp02f.yandex-team.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Do, 2015-04-02 at 21:08 +0300, Roman Gushchin wrote:
> >>  The next question I have is about the behavior of the new setting
> >>  in the presence of an RA MTU option.  It seems like the sysctl
> >>  doesn't override that RA MTU option, but rather just clamps it.
> >>
> >>  And then if it's in range, this controls only whether the default
> >>  route has it's MTU adjusted.
> >>
> >>  That doesn't make any sense to me if we then go and do the
> >>  rt6_mtu_change() call unconditionally.  The route metric update
> >>  and the rt6_mtu_change() go hand in hand.
> >
> > Agreed but that gets interesting:
> >
> > I guess during testing the cnf.mtu6 value was equal to the newly
> > announced mtu value, so the rt6_mtu_change call does not happen. We
> > update cnf.mtu6 so a second RA packet would actually bring the system
> > into the desired state but we have a moment where the default route
> > carries a too big MTU. That's not good.
> 
> Agreed.
> 
> > Easiest solution is to reorder those calls but that also leaves us with
> > a time frame where we carry the incorrect MTU on the default route.
> > Otherwise we must conditionally filter out the default routes.
> > Roman, any ideas?
> 
> I think, such approach will work on practise, but looks not very beatiful.
> 
> May be, a better idea is to serarate per-route and per-device MTU,
> so an updating of per-device MTU will not affect per-route MTU.
> Actual MTU can always been calculated as min(route_mtu, device_mtu),
> but we wouldn't need to update mtu on each route on receiving RA MTU option, 
> for instance.
> 
> Do you see any problems with such approach?

If I understood you correct this actually seems to be quite an intrusive
change? :/ Can you show me some code how to do this?

I would also dislike adding a filtering capability to the route mtu
updates. Currently I don't have a god idea, sorry.

Bye,
Hannes
