From: Romain Perier <romain.perier@free-electrons.com>
Subject: Re: [PATCH 3/4] net: dsa: mv88e6xxx: Add support for ethernet switch
 88E6341/88E6141
Date: Mon, 19 Dec 2016 15:58:17 +0100
Message-ID: <bc0af369-28a9-af38-723b-d4b182bb153e@free-electrons.com>
References: <20161219141610.30934-1-romain.perier@free-electrons.com>
 <20161219141610.30934-4-romain.perier@free-electrons.com>
 <20161219145227.GC10048@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; Format="flowed"
Content-Transfer-Encoding: quoted-printable
Cc: Mark Rutland <mark.rutland@arm.com>, devicetree@vger.kernel.org,
 Florian Fainelli <f.fainelli@gmail.com>, Jason Cooper <jason@lakedaemon.net>,
 Pawel Moll <pawel.moll@arm.com>,
 Vivien Didelot <vivien.didelot@savoirfairelinux.com>, netdev@vger.kernel.org,
 Ian Campbell <ijc+devicetree@hellion.org.uk>,
 Nadav Haklai <nadavh@marvell.com>, Rob Herring <robh+dt@kernel.org>,
 Kumar Gala <galak@codeaurora.org>,
 Gregory Clement <gregory.clement@free-electrons.com>,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20161219145227.GC10048@lunn.ch>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

Le 19/12/2016 =E0 15:52, Andrew Lunn a =E9crit :
> Hi Romain
>
>> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xx=
x/chip.c
>> index 76d944e..72ba24b 100644
>> --- a/drivers/net/dsa/mv88e6xxx/chip.c
>> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
>> @@ -4086,6 +4086,20 @@ static const struct mv88e6xxx_info mv88e6xxx_tabl=
e[] =3D {
>>  		.ops =3D &mv88e6321_ops,
>>  	},
>>
>> +	[MV88E6341] =3D {
>> +		.prod_num =3D PORT_SWITCH_ID_PROD_NUM_6341,
>> +		.family =3D MV88E6XXX_FAMILY_6352,
>> +		.name =3D "Marvell 88E6341",
>> +		.num_databases =3D 4096,
>> +		.num_ports =3D 6,
>> +		.port_base_addr =3D 0x10,
>> +		.global1_addr =3D 0x1b,
>> +		.age_time_coeff =3D 15000,
>> +		.tag_protocol =3D DSA_TAG_PROTO_EDSA,
>> +		.flags =3D MV88E6XXX_FLAGS_FAMILY_6352,
>> +		.ops =3D &mv88e6352_ops,
>
> Even if it i 100% compatible with the 6532, you should still add an
> ops structure for it. All chips have their own, even when the are
> exactly the same as other in the family.

Ack, I will fix this.

>
>> --- a/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
>> +++ b/drivers/net/dsa/mv88e6xxx/mv88e6xxx.h
>> @@ -86,6 +86,7 @@
>>  #define PORT_SWITCH_ID_PROD_NUM_6097	0x099
>>  #define PORT_SWITCH_ID_PROD_NUM_6131	0x106
>>  #define PORT_SWITCH_ID_PROD_NUM_6320	0x115
>> +#define PORT_SWITCH_ID_PROD_NUM_6341	0x340
>>  #define PORT_SWITCH_ID_PROD_NUM_6123	0x121
>>  #define PORT_SWITCH_ID_PROD_NUM_6161	0x161
>
> Ah, err..
>
> These should be in numerical order of the macro.
> PORT_SWITCH_ID_PROD_NUM_6320 is however in the wrong place.  Please
> put the 6341 after the 6321.

good catch, ok.

Thanks,
Romain
