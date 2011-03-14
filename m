From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/4] netfilter: xt_connlimit: fix daddr connlimit in SNAT
 scenario
Date: Mon, 14 Mar 2011 19:32:11 +0100
Message-ID: <4D7E5F2B.1070007@trash.net>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com> <alpine.LNX.2.01.1103141310140.27542@obet.zrqbmnf.qr> <AANLkTi=QgVBVAPcTmb_La=VJOLq5LmGPqMfw7bbCuByP@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59811 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab1CNScP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 14:32:15 -0400
In-Reply-To: <AANLkTi=QgVBVAPcTmb_La=VJOLq5LmGPqMfw7bbCuByP@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14.03.2011 13:42, Changli Gao wrote:
> On Mon, Mar 14, 2011 at 8:26 PM, Jan Engelhardt <jengelh@medozas.de> =
wrote:
>> On Monday 2011-03-14 07:50, Changli Gao wrote:
>>
>>> We use the reply tuples when limiting the connections by the destin=
ation
>>> addresses, however, in SNAT scenario, the final reply tuples won't =
be
>>> ready until SNAT is done in POSTROUING or INPUT chain
>>
>> If I am not mistaken: if you do daddr counting, SNAT is irrelevant.
>> Consider ruleset
>>  -t nat -A PREROUTING -p tcp --dport 80 -j DNAT --to 1.2.3.4:80
>>  -t nat -A PREROUTING -p tcp --dport 443 -j DNAT --to 1.2.3.5:443
>>
>> The tuple will first be (as per conntrack -L):
>>  src=3Dhome dst=3Drouter src=3Drouter dst=3Dhome
>> After DNAT:
>>  src=3Dhome dst=3Drouter src=3D1.2.3.4 dst=3Dhome
>>
>> Thus looking at the src of the reply tuple seems correct =E2=80=94 a=
t least this
>> is what was wanted, counting per stashed servers (=3D1 customer), no=
t per
>> globally visible address.
>>
>=20
> Yes, you are correct only when there is no SNAT rule. If there is an =
SNAT rule:
>=20
> -t nat -A POSTROUTING -p tcp --dport 80 -j SNAT --to-source 192.168.0=
=2E1
>=20
> the final tuples will be:
> src =3D home dst =3D router src=3D1.2.3.4 dst=3D192.168.0.1
>=20
> However, the tuple saved by connlimit is src=3D1.2.3.4 dst=3Dhome, so=
 this
> conn will be removed later as there isn't any conntrack, which has
> this tuple in any direction.
>=20
> You can't prevent a user from doing such a configuration, although yo=
u
> might think it is stupid to do that.
>=20
> Thanks for your review.

Jan, please let me know whether you want me to apply these patches.
Thanks.
