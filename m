From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: Re: [PATCH v2 5/6] ARM: at91: change compatibility string for sama5d3x
 gem
Date: Thu, 24 Jul 2014 17:57:42 +0200
Message-ID: <53D12CF6.6070502@atmel.com>
References: <cover.1406192657.git.cyrille.pitchen@atmel.com> <b8cbfb4e8d5d156d477634164c21cfa6f509c4ea.1406192657.git.cyrille.pitchen@atmel.com> <20140724151529.GA26190@leverpostej>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"soren.brinkmann@xilinx.com" <soren.brinkmann@xilinx.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140724151529.GA26190@leverpostej>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 24/07/2014 17:15, Mark Rutland a =E9crit :
> On Thu, Jul 24, 2014 at 12:51:02PM +0100, Cyrille Pitchen wrote:
>> this new compatibility string prevents macb/gem driver from using th=
e
>> scatter-gather and gso features on sama5d3x boards.
>=20
> What will happen were the driver to attempt to use the features on th=
is
> board?
>=20
> How will this affect existing DTBs?
>=20
> Thanks,
> Mark.
>
Hi Mark,

patch 2 for then scatter-gather feature introducted a new compatible st=
ring
"atmel,sama5d3-gem". Its associated config has the MACB_CAPS_SG_DISABLE=
D flag
so the feature is not available indeed.

patch 2 also set the very same flag for the config associated to the al=
ready=20
existing strings "cdns,pc302-gem" and "cdns,gem". Then if you don't upd=
ate=20
your device tree, the scatter-gather feature won't be enabled for gem a=
nyway.=20
However SG feature will be enabled for the old macb.

The main idea is to do the change in two steps to avoid indroducing bug=
s. This
series of patches is the first step. Later an additionnal patch may be=20
introduced to enable SG feature for gem on all platforms but sama5d3x. =
This=20
should be done by removing the MACB_CAPS_SG_DISABLED flag from pc302gem=
_config.
Till then you don't need to update your device tree.

=46or now, the SG feature is known to be broken on sama5d3x and there i=
s work in=20
progress with Cadence support to fix this issue. It seems to be specifi=
c to=20
sama5d3x gem. SG feature was successfully tested on sama5d3x macb and a=
lso on=20
sama5d4 gem.

Regards,

Cyrille

>>
>> Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
>> ---
>>  arch/arm/boot/dts/sama5d3_gmac.dtsi | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/arch/arm/boot/dts/sama5d3_gmac.dtsi b/arch/arm/boot/dts=
/sama5d3_gmac.dtsi
>> index a6cb050..de5ed59 100644
>> --- a/arch/arm/boot/dts/sama5d3_gmac.dtsi
>> +++ b/arch/arm/boot/dts/sama5d3_gmac.dtsi
>> @@ -74,7 +74,7 @@
>>  			};
>> =20
>>  			macb0: ethernet@f0028000 {
>> -				compatible =3D "cdns,pc302-gem", "cdns,gem";
>> +				compatible =3D "atmel,sama5d3-gem";
>>  				reg =3D <0xf0028000 0x100>;
>>  				interrupts =3D <34 IRQ_TYPE_LEVEL_HIGH 3>;
>>  				pinctrl-names =3D "default";
>> --=20
>> 1.8.2.2
>>
>>
>> _______________________________________________
>> linux-arm-kernel mailing list
>> linux-arm-kernel@lists.infradead.org
>> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
>>
