From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [PATCH] net: enic: convert to hw_features
Date: Thu, 7 Apr 2011 22:45:06 +0200
Message-ID: <20110407204506.GA18509@rere.qmqm.pl>
References: <20110407124348.BB13A138ED@rere.qmqm.pl> <C9C3641D.23F23%roprabhu@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Christian Benvenuti <benve@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	David Wang <dwang2@cisco.com>
To: roprabhu <roprabhu@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:40248 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756942Ab1DGUpI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2011 16:45:08 -0400
Content-Disposition: inline
In-Reply-To: <C9C3641D.23F23%roprabhu@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 07, 2011 at 12:52:45PM -0700, roprabhu wrote:
> Thanks michal.
>=20
> One small comment below,
>=20
> On 4/7/11 5:43 AM, "Micha=B3 Miros=B3aw" <mirq-linux@rere.qmqm.pl> wr=
ote:
> > As the driver uses GRO and not LRO, LRO settings are ignored anyway
> > and are removed here to avoid confusion.
[...]
> > diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_re=
s.c
> > index f111a37..6e5c635 100644
> > --- a/drivers/net/enic/enic_res.c
> > +++ b/drivers/net/enic/enic_res.c
> > @@ -98,9 +98,9 @@ int enic_get_vnic_config(struct enic *enic)
> > "vNIC MAC addr %pM wq/rq %d/%d mtu %d\n",
> > enic->mac_addr, c->wq_desc_count, c->rq_desc_count, c->mtu);
> > dev_info(enic_get_dev(enic), "vNIC csum tx/rx %d/%d "
> > -  "tso/lro %d/%d intr timer %d usec rss %d\n",
> > +  "tso %d intr timer %d usec rss %d\n",
> > ENIC_SETTING(enic, TXCSUM), ENIC_SETTING(enic, RXCSUM),
> > -  ENIC_SETTING(enic, TSO), ENIC_SETTING(enic, LRO),
> > +  ENIC_SETTING(enic, TSO),
> > c->intr_timer_usec, ENIC_SETTING(enic, RSS));
> > =20
> You are right about the driver using GRO and not LRO by default. But =
the
> config entry from where enic gets this setting is still called LRO fo=
r
> reasons out of the scope of the driver. Yes, I see that it can lead t=
o
> confusion. So, we will need to retain the ENIC_SETTING(enic, LRO) but=
 fix
> the name of that setting.  Thanks for pointing this out. We will fix =
this
> and any other changes if required and resubmit.

I removed this part because now network core is always turning on GRO
by default regardless of what driver sets in features at init time.
That's on purpose, since GRO is purely a software feature.

OTOH, if you want to forcibly disable GRO when LRO is not set in enic's
config, then you can do so in ndo_fix_features callback.

Best Regards,
Micha=B3 Miros=B3aw
