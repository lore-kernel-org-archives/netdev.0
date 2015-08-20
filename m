From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Thu, 20 Aug 2015 14:07:34 -0700 (PDT)
Message-ID: <20150820.140734.195153496258370626.davem@davemloft.net>
References: <55D4AFCA.7080300@6wind.com>
	<20150820135307.3ce12f69@griffin>
	<55D5E4AF.7020409@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jbenc@redhat.com, vincent@bernat.im, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57200 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751761AbbHTVHf convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:07:35 -0400
In-Reply-To: <55D5E4AF.7020409@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Thu, 20 Aug 2015 16:31:11 +0200

> Le 20/08/2015 13:53, Jiri Benc a =E9crit :
>> On Wed, 19 Aug 2015 18:33:14 +0200, Nicolas Dichtel wrote:
>>> Probably better to introduce veth netlink attribute then, something
>>> like
>>> IFLA_VETH_PEER and keeps IFLA_LINK_NETNSID.
>>
>> I'd prefer IFLA_PEER. More generic attribute will be helpful should =
we
>> introduce an interface similar to veth in the future.s
> Ok.
>=20
>>
>> Also, I'd not combine IFLA_LINK_NETNSID with IFLA_PEER. There might
>> very well be an interface in the future that will need both IFLA_LIN=
K
>> and
>> IFLA_PEER and this would just create a confusion. It may be unlikely
>> but the attributes are cheap and it doesn't make sense to design uAP=
I
>> in a way that might bring problems in the future.
> Ok, but then this IFLA_PEER can include the ifindex and the nsid. No
> need
> to have two new attributes.
>=20
>>
>>> I also don't know what is the best way to handle this. veth adverti=
ses
>>> its peer via IFLA_LINK since 4.1, so it's too late to change it for
>>> this
>>> release.
>>
>> Apparently we need to pick our poison. Either way, we break somethin=
g.
> Sure. I would prefer to have the same mechanism in all version, but I
> can
> live with the other solution.
>=20
> David, any thoughts about this?

You can't break the 4.1 semantics, it's in a released kernel and people
_ARE_ using it.
