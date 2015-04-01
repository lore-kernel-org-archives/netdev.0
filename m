From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Wed, 01 Apr 2015 21:27:27 +0200
Message-ID: <1427916447.1816412.248215129.072B6ABF@webmail.messagingengine.com>
References: <1427834148.979686.247747037.29964C1B@webmail.messagingengine.com>
 <20150331.164923.229749666073516444.davem@davemloft.net>
 <68621427882330@webcorp01g.yandex-team.ru>
 <20150401.135532.1368728758929086692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, klamm@yandex-team.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:39297 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753100AbbDAT12 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Apr 2015 15:27:28 -0400
Received: from compute2.internal (compute2.nyi.internal [10.202.2.42])
	by mailout.nyi.internal (Postfix) with ESMTP id BA1DD20BDF
	for <netdev@vger.kernel.org>; Wed,  1 Apr 2015 15:27:24 -0400 (EDT)
In-Reply-To: <20150401.135532.1368728758929086692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Wed, Apr 1, 2015, at 19:55, David Miller wrote:
> From: Roman Gushchin <klamm@yandex-team.ru>
> Date: Wed, 01 Apr 2015 12:58:50 +0300
>=20
> > 31.03.2015, 23:49, "David Miller" <davem@davemloft.net>:
> >> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> >> Date: Tue, 31 Mar 2015 22:35:48 +0200
> >>> =C2=A0Could you quickly comment on what you had in mind? I guess =
it is about
> >>> =C2=A0handling RA in user space on the end hosts and overwriting =
MTU during
> >>> =C2=A0insertion of the routes?
> >>
> >> Even after reading your email I have no idea why you can't just ha=
ve
> >> RA provide a 1500 byte MTU, everything else uses the device's 9000
> >> MTU, problem solved?
> >=20
> > Because the MTU (provided by RA) is assigned to the device.
>=20
> Ok, that severely limits the usefulness of this option I guess.
>=20
> The next question I have is about the behavior of the new setting
> in the presence of an RA MTU option.  It seems like the sysctl
> doesn't override that RA MTU option, but rather just clamps it.
>=20
> And then if it's in range, this controls only whether the default
> route has it's MTU adjusted.
>=20
> That doesn't make any sense to me if we then go and do the
> rt6_mtu_change() call unconditionally.  The route metric update
> and the rt6_mtu_change() go hand in hand.

Agreed but that gets interesting:

I guess during testing the cnf.mtu6 value was equal to the newly
announced mtu value, so the rt6_mtu_change call does not happen. We
update cnf.mtu6 so a second RA packet would actually bring the system
into the desired state but we have a moment where the default route
carries a too big MTU. That's not good.

Easiest solution is to reorder those calls but that also leaves us with
a time frame where we carry the incorrect MTU on the default route.
Otherwise we must conditionally filter out the default routes.

Roman, any ideas?

Thanks,
Hannes
