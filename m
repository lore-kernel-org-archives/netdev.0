From: Marcin Wojtas <mw@semihalf.com>
Subject: Re: [PATCH v2 net 1/6] net: mvneta: add configuration for MBUS
 windows access protection
Date: Thu, 26 Nov 2015 19:31:51 +0100
Message-ID: <CAPv3WKdnNFF47_EeB852ui_2mWDuoOAycoDwxVM5dkGPYAOMCA@mail.gmail.com>
References: <1448561293-16431-1-git-send-email-mw@semihalf.com>
	<1448561293-16431-2-git-send-email-mw@semihalf.com>
	<20151126192522.25b297ec@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-kernel@vger.kernel.org,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Jason Cooper <jason@lakedaemon.net>,
	=?UTF-8?Q?Gregory_Cl=C3=A9ment?=
	<gregory.clement@free-electrons.com>,
	Simon Guinot <simon.guinot@sequanux.org>, nadavh@marvell.com,
	Lior Amsalem <alior@marvell.com>,
	Evan Wang <xswang@marvell.com>,
	Yair Mahalalel <myair@marvell.com>, nitroshift@yahoo.com,
	Grzegorz Jaszczyk <jaz@semihalf.com>,
	Tomasz Nowicki <tn@semihalf.com>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151126192522.25b297ec@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Thomas,

2015-11-26 19:25 GMT+01:00 Thomas Petazzoni
<thomas.petazzoni@free-electrons.com>:
> Marcin,
>
> On Thu, 26 Nov 2015 19:08:08 +0100, Marcin Wojtas wrote:
>> This commit adds missing configuration of MBUS windows access protection
>> in mvneta_conf_mbus_windows function - a dedicated variable for that
>> purpose remained there unused since v3.8 initial mvneta support. Because
>> of that the register contents were inherited from the bootloader.
>>
>> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
>> Reviewed-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
>> Cc: <stable@vger.kernel.org> # v3.8+
>> Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network
>> unit")
>
> Is this actually fixing a user visible problem? If not, then I am not
> sure it qualifies for stable.

Indeed, it's not fixing a visible thing, unless you resume from
suspend to ram. However, the original driver declares and updates
'win_protect ' variable, which have remained unused for past 3 years:)
If you think it's not worth cc'ing stable despite that, I will remove
the notification.

>
>> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
>> index e84c7f2..c4327b9 100644
>> --- a/drivers/net/ethernet/marvell/mvneta.c
>> +++ b/drivers/net/ethernet/marvell/mvneta.c
>> @@ -62,6 +62,7 @@
>>  #define MVNETA_WIN_SIZE(w)                      (0x2204 + ((w) << 3))
>>  #define MVNETA_WIN_REMAP(w)                     (0x2280 + ((w) << 2))
>>  #define MVNETA_BASE_ADDR_ENABLE                 0x2290
>> +#define MVNETA_ACCESS_PROTECT_ENABLE         0x2294
>
> Spaces are used for indentation in the definitions of all other
> constants in this driver, so I think you should stick with this
> convention, at least to remain consistent.
>

Ok.

>>  #define MVNETA_PORT_CONFIG                      0x2400
>>  #define      MVNETA_UNI_PROMISC_MODE            BIT(0)
>>  #define      MVNETA_DEF_RXQ(q)                  ((q) << 1)
>> @@ -3188,9 +3189,11 @@ static void mvneta_conf_mbus_windows(struct mvneta_port *pp,
>>
>>               win_enable &= ~(1 << i);
>>               win_protect |= 3 << (2 * i);
>> +
>
> Unneeded change.
>

Indeed, my mistake.

Thanks,
Marcin
