From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Wed, 01 Apr 2015 13:55:32 -0400 (EDT)
Message-ID: <20150401.135532.1368728758929086692.davem@davemloft.net>
References: <1427834148.979686.247747037.29964C1B@webmail.messagingengine.com>
	<20150331.164923.229749666073516444.davem@davemloft.net>
	<68621427882330@webcorp01g.yandex-team.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: klamm@yandex-team.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <68621427882330@webcorp01g.yandex-team.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Roman Gushchin <klamm@yandex-team.ru>
Date: Wed, 01 Apr 2015 12:58:50 +0300

> 31.03.2015, 23:49, "David Miller" <davem@davemloft.net>:
>> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Date: Tue, 31 Mar 2015 22:35:48 +0200
>>> =A0Could you quickly comment on what you had in mind? I guess it is=
 about
>>> =A0handling RA in user space on the end hosts and overwriting MTU d=
uring
>>> =A0insertion of the routes?
>>
>> Even after reading your email I have no idea why you can't just have
>> RA provide a 1500 byte MTU, everything else uses the device's 9000
>> MTU, problem solved?
>=20
> Because the MTU (provided by RA) is assigned to the device.

Ok, that severely limits the usefulness of this option I guess.

The next question I have is about the behavior of the new setting
in the presence of an RA MTU option.  It seems like the sysctl
doesn't override that RA MTU option, but rather just clamps it.

And then if it's in range, this controls only whether the default
route has it's MTU adjusted.

That doesn't make any sense to me if we then go and do the
rt6_mtu_change() call unconditionally.  The route metric update
and the rt6_mtu_change() go hand in hand.
