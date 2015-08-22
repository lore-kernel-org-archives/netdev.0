From: Vincent Bernat <vincent@bernat.im>
Subject: Re: [PATCH] veth: replace iflink by a dedicated symlink in sysfs
Date: Sat, 22 Aug 2015 22:51:01 +0200
Message-ID: <87si7bt5ca.fsf@zoro.exoscale.ch>
References: <55D4AFCA.7080300@6wind.com> <20150820135307.3ce12f69@griffin>
	<55D5E4AF.7020409@6wind.com>
	<20150820.140734.195153496258370626.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, jbenc@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bart.luffy.cx ([78.47.78.131]:54173 "EHLO bart.luffy.cx"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750823AbbHVUvE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Aug 2015 16:51:04 -0400
In-Reply-To: <20150820.140734.195153496258370626.davem@davemloft.net> (David
	Miller's message of "Thu, 20 Aug 2015 14:07:34 -0700 (PDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 =E2=9D=A6 20 ao=C3=BBt 2015 14:07 -0700, David Miller <davem@davemloft=
=2Enet>=C2=A0:

>>>> I also don't know what is the best way to handle this. veth advert=
ises
>>>> its peer via IFLA_LINK since 4.1, so it's too late to change it fo=
r
>>>> this
>>>> release.
>>>
>>> Apparently we need to pick our poison. Either way, we break somethi=
ng.
>> Sure. I would prefer to have the same mechanism in all version, but =
I
>> can live with the other solution.
>>=20
>> David, any thoughts about this?
>
> You can't break the 4.1 semantics, it's in a released kernel and peop=
le
> _ARE_ using it.

I had a look at what other kind of daemons may exploit the pre-4.1
semantics (of not having an infinite loop when following iflink) and
failed to find any other users than "lldpd". Other LLDP daemons (lldpad=
,
ladvd, openlldpd) have other ways to find the lower interface. I would
also have thought that NetSNMP would use it to implement ifStackTable
but it doesn't in fact implement this table.
--=20
It were not best that we should all think alike; it is difference of op=
inion
that makes horse-races.
		-- Mark Twain, "Pudd'nhead Wilson's Calendar"
