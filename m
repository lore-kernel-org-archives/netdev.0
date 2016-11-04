From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH 1/2] net: ethernet: nb8800: Do not apply TX delay at MAC
 level
Date: Fri, 4 Nov 2016 16:29:09 +0100
Message-ID: <581CA945.70601@laposte.net>
References: <581CA300.1060609@laposte.net> <20161104151151.GF3600@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?TcOlbnMgUnVsbGfDpXJk?= <mans@mansr.com>,
        "David S. Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>, Mason <slash.tmp@free.fr>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161104151151.GF3600@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andrew,

On 11/04/2016 04:11 PM, Andrew Lunn wrote:
> On Fri, Nov 04, 2016 at 04:02:24PM +0100, Sebastian Frias wrote:
>> The delay can be applied at PHY or MAC level, but since
>> PHY drivers will apply the delay at PHY level when using
>> one of the "internal delay" declinations of RGMII mode
>> (like PHY_INTERFACE_MODE_RGMII_TXID), applying it again
>> at MAC level causes issues.
>>
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

This part is specific to the Tango architecture, as noted by the
function name "nb8800_tangox_init".

Also the register used here is Sigma-specific (i.e.: not related to the
Aurora VLSI MAC, "au-nb8800")

The thing is that without this patch if we set
phy-connection-type="rgmii-txid" on the DT, then both, the PHY and the
MAC, will apply the delay.

Best regards,

Sebastian

> I guess it is a small number, because doesn't it require the PHY is
> also broken, not adding a delay when it should?
> 
>      Andrew
> 
