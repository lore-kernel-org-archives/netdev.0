From: =?iso-8859-1?Q?M=E5ns_Rullg=E5rd?= <mans@mansr.com>
Subject: Re: [PATCH 1/2] net: ethernet: nb8800: Do not apply TX delay at MAC level
Date: Fri, 04 Nov 2016 15:27:55 +0000
Message-ID: <yw1xa8dfjmdg.fsf@unicorn.mansr.com>
References: <581CA300.1060609@laposte.net> <20161104151151.GF3600@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: Sebastian Frias <sf84@laposte.net>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104151151.GF3600@lunn.ch> (Andrew Lunn's message of "Fri, 4
        Nov 2016 16:11:51 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Lunn <andrew@lunn.ch> writes:

> On Fri, Nov 04, 2016 at 04:02:24PM +0100, Sebastian Frias wrote:
>> The delay can be applied at PHY or MAC level, but since
>> PHY drivers will apply the delay at PHY level when using
>> one of the "internal delay" declinations of RGMII mode
>> (like PHY_INTERFACE_MODE_RGMII_TXID), applying it again
>> at MAC level causes issues.

If this is correct, most of the PHY drivers are broken.

>> Signed-off-by: Sebastian Frias <sf84@laposte.net>
>> ---
>>  drivers/net/ethernet/aurora/nb8800.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/drivers/net/ethernet/aurora/nb8800.c b/drivers/net/ethernet/aurora/nb8800.c
>> index b59aa35..d2855c9 100644
>> --- a/drivers/net/ethernet/aurora/nb8800.c
>> +++ b/drivers/net/ethernet/aurora/nb8800.c
>> @@ -1282,7 +1282,7 @@ static int nb8800_tangox_init(struct net_device *dev)
>>  		break;
>>  
>>  	case PHY_INTERFACE_MODE_RGMII_TXID:
>> -		pad_mode = PAD_MODE_RGMII | PAD_MODE_GTX_CLK_DELAY;
>> +		pad_mode = PAD_MODE_RGMII;
>>  		break;
>
> How many boards use this Ethernet driver? How many boards are your
> potentially breaking, because they need this delay?
>
> I guess it is a small number, because doesn't it require the PHY is
> also broken, not adding a delay when it should?

What if the PHY doesn't have that option?

-- 
Måns Rullgård
