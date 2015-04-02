From: Roman Gushchin <klamm@yandex-team.ru>
Subject: Re: [PATCH v3] net: sysctl for RA default route MTU
Date: Thu, 02 Apr 2015 21:08:37 +0300
Message-ID: <36791427998117@webcorp02f.yandex-team.ru>
References: <1427834148.979686.247747037.29964C1B@webmail.messagingengine.com>
	 <20150331.164923.229749666073516444.davem@davemloft.net>
	 <68621427882330@webcorp01g.yandex-team.ru>
	 <20150401.135532.1368728758929086692.davem@davemloft.net> <1427916447.1816412.248215129.072B6ABF@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1427916447.1816412.248215129.072B6ABF@webmail.messagingengine.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>> =9AThe next question I have is about the behavior of the new setting
>> =9Ain the presence of an RA MTU option. =9AIt seems like the sysctl
>> =9Adoesn't override that RA MTU option, but rather just clamps it.
>>
>> =9AAnd then if it's in range, this controls only whether the default
>> =9Aroute has it's MTU adjusted.
>>
>> =9AThat doesn't make any sense to me if we then go and do the
>> =9Art6_mtu_change() call unconditionally. =9AThe route metric update
>> =9Aand the rt6_mtu_change() go hand in hand.
>
> Agreed but that gets interesting:
>
> I guess during testing the cnf.mtu6 value was equal to the newly
> announced mtu value, so the rt6_mtu_change call does not happen. We
> update cnf.mtu6 so a second RA packet would actually bring the system
> into the desired state but we have a moment where the default route
> carries a too big MTU. That's not good.

Agreed.

> Easiest solution is to reorder those calls but that also leaves us wi=
th
> a time frame where we carry the incorrect MTU on the default route.
> Otherwise we must conditionally filter out the default routes.
> Roman, any ideas?

I think, such approach will work on practise, but looks not very beatif=
ul.

May be, a better idea is to serarate per-route and per-device MTU,
so an updating of per-device MTU will not affect per-route MTU.
Actual MTU can always been calculated as min(route_mtu, device_mtu),
but we wouldn't need to update mtu on each route on receiving RA MTU op=
tion,=20
for instance.

Do you see any problems with such approach?

Thanks,
Roman
