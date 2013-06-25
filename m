From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Tue, 25 Jun 2013 23:16:40 +0200
Message-ID: <51CA08B8.9030001@xdin.com>
References: <51C87746.1010002@xdin.com> <1372097797.1245.12.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	balferreira <balferreira@googlemail.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:51377 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750971Ab3FYV0A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Jun 2013 17:26:00 -0400
In-Reply-To: <1372097797.1245.12.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-06-24 20:16, Joe Perches wrote:
> On Mon, 2013-06-24 at 18:43 +0200, Arvid Brodin wrote:
>> High-availability Seamless Redundancy ("HSR") provides instant failo=
ver
>> redundancy for Ethernet networks. It requires a special network topo=
logy where
>> all nodes are connected in a ring (each node having two physical net=
work
>> interfaces). It is suited for applications that demand high availabi=
lity and
>> very short reaction time.
>=20
> trivia:
>=20
> You should probably use checkpatch.pl --strict for files in net.
> It will suggest aligning arguments in the more common net style.

Does this mean I should also remove spaces after casts (IMO this would =
reduce readability
somewhat)?


>>  net/hsr/hsr_device.h          |  30 +++
>>  net/hsr/hsr_framereg.h        |  54 ++++
>>  net/hsr/hsr_main.h            | 167 ++++++++++++
>>  net/hsr/hsr_netlink.h         |  74 ++++++
>=20
> Maybe some of these .h files should go into include/net/...
>=20
> A future version of checkpatch may read all the include
> files and exempt any CamelCase defines/typedefs/functions
> from CamelCase warnings.

I cannot judge if these files should go into include/net/ or not. Where=
 can I get a final
say on this?

Some of the definitions in hsr_netlink.h are needed by userspace tools =
that want to listen
for ring errors etc from the HSR driver, so it would be a good thing if=
 this file could be
part of the kernel headers install. How can I accomplish this?


>> +	if ((skb->protocol !=3D htons(ETH_P_PRP)) ||
>> +			(hsr_ethhdr->ethhdr.h_proto !=3D htons(ETH_P_PRP))) {
>=20
> Please align indents after the appropriate open parenthesis.=20
>=20
> 	if (foo ||
> 	    bar) {
>=20
>> +bool is_hsr_master(struct net_device *dev)
>> +{
>> +	if (!dev) {
>> +		WARN_ON_ONCE(1);
>> +		return 0;
>> +	}
>> +	if (!dev->netdev_ops) {
>> +		WARN_ON_ONCE(1);
>> +		return 0;
>> +	}
>=20
> probably better to combine and give a textual reason

Or perhaps better to remove them altogether? I guess you could call the=
m debug statements...


>> diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
> []
>> +#define HSR_LIFE_CHECK_INTERVAL		 2000 /* ms */
>> +#define HSR_NODE_FORGET_TIME		60000 /* ms */
>> +#define HSR_ANNOUNCE_INTERVAL		  100 /* ms */
>=20
> Odd alignment

Only because of the plus chars added by diff. :)


>> diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
> []
>> +static const struct nla_policy hsr_genl_policy[HSR_A_MAX + 1] =3D {
>> +	[HSR_A_NODE_ADDR] =3D { .type =3D NLA_BINARY, .len =3D ETH_ALEN },
>> +	[HSR_A_NODE_ADDR_B] =3D { .type =3D NLA_BINARY, .len =3D ETH_ALEN =
},
>> +	[HSR_A_IFINDEX] =3D { .type =3D NLA_U32 },
>> +	[HSR_A_IF1_AGE] =3D { .type =3D NLA_U32 }, /* Actually signed 32-b=
it */
>> +	[HSR_A_IF2_AGE] =3D { .type =3D NLA_U32 }, /* Actually signed 32-b=
it */
>=20
> Why not use NLA_S32?

We need the code to work on older kernels as well, where NLA_S32 does n=
ot exist. Actually,
these values never become negative with the current code. During develo=
pment we returned a
negative value to mean "out of range" but we have switched to INT_MAX i=
nstead. So perhaps
it's best just to remove these comments?


--=20
Arvid Brodin | Consultant (Linux)
T: +46-8-56254286 | M: +46-70-9714286 | arvid.brodin@xdin.com
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
