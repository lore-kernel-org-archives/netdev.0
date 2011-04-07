From: roprabhu <roprabhu@cisco.com>
Subject: Re: [PATCH] net: enic: convert to hw_features
Date: Thu, 07 Apr 2011 14:55:11 -0700
Message-ID: <C9C380CF.23F57%roprabhu@cisco.com>
References: <20110407204506.GA18509@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Christian Benvenuti <benve@cisco.com>,
	Vasanthy Kolluri <vkolluri@cisco.com>,
	David Wang <dwang2@cisco.com>
To: =?ISO-8859-2?B?TWljaGGz?= =?ISO-8859-2?B?IE1pcm9zs2F3?=
	<mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:22381 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751828Ab1DGVzM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2011 17:55:12 -0400
In-Reply-To: <20110407204506.GA18509@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 4/7/11 1:45 PM, "Micha=B3 Miros=B3aw" <mirq-linux@rere.qmqm.pl> wrot=
e:

> On Thu, Apr 07, 2011 at 12:52:45PM -0700, roprabhu wrote:
>> Thanks michal.
>>=20
>> One small comment below,
>>=20
>> On 4/7/11 5:43 AM, "Micha=B3 Miros=B3aw" <mirq-linux@rere.qmqm.pl> w=
rote:
>>> As the driver uses GRO and not LRO, LRO settings are ignored anyway
>>> and are removed here to avoid confusion.
> [...]
>>> diff --git a/drivers/net/enic/enic_res.c b/drivers/net/enic/enic_re=
s.c
>>> index f111a37..6e5c635 100644
>>> --- a/drivers/net/enic/enic_res.c
>>> +++ b/drivers/net/enic/enic_res.c
>>> @@ -98,9 +98,9 @@ int enic_get_vnic_config(struct enic *enic)
>>> "vNIC MAC addr %pM wq/rq %d/%d mtu %d\n",
>>> enic->mac_addr, c->wq_desc_count, c->rq_desc_count, c->mtu);
>>> dev_info(enic_get_dev(enic), "vNIC csum tx/rx %d/%d "
>>> -  "tso/lro %d/%d intr timer %d usec rss %d\n",
>>> +  "tso %d intr timer %d usec rss %d\n",
>>> ENIC_SETTING(enic, TXCSUM), ENIC_SETTING(enic, RXCSUM),
>>> -  ENIC_SETTING(enic, TSO), ENIC_SETTING(enic, LRO),
>>> +  ENIC_SETTING(enic, TSO),
>>> c->intr_timer_usec, ENIC_SETTING(enic, RSS));
>>> =20
>> You are right about the driver using GRO and not LRO by default. But=
 the
>> config entry from where enic gets this setting is still called LRO f=
or
>> reasons out of the scope of the driver. Yes, I see that it can lead =
to
>> confusion. So, we will need to retain the ENIC_SETTING(enic, LRO) bu=
t fix
>> the name of that setting.  Thanks for pointing this out. We will fix=
 this
>> and any other changes if required and resubmit.
>=20
> I removed this part because now network core is always turning on GRO
> by default regardless of what driver sets in features at init time.
> That's on purpose, since GRO is purely a software feature.
>=20
> OTOH, if you want to forcibly disable GRO when LRO is not set in enic=
's
> config, then you can do so in ndo_fix_features callback.
>=20
Ok thanks michal.=20

