From: Joshua Henderson <joshua.henderson@microchip.com>
Subject: Re: [PATCH] net: phy: Add support for SMSC LAN8740 PHY
Date: Sat, 9 Jan 2016 04:43:54 -0700
Message-ID: <5690F27A.6090500@microchip.com>
References: <1452301040-4392-1-git-send-email-joshua.henderson@microchip.com>
 <20160109013655.GA28813@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	<netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160109013655.GA28813@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/8/2016 6:36 PM, Andrew Lunn wrote:
> On Fri, Jan 08, 2016 at 05:57:20PM -0700, Joshua Henderson wrote:
>> LAN8740 has a different phy_id than LAN8710/LAN8720.
>>
>> Signed-off-by: Joshua Henderson <joshua.henderson@microchip.com>
>> ---
>>  drivers/net/phy/smsc.c |   24 ++++++++++++++++++++++++
>>  1 file changed, 24 insertions(+)
>>
>> diff --git a/drivers/net/phy/smsc.c b/drivers/net/phy/smsc.c
>> index dc2da87..34021a5 100644
>> --- a/drivers/net/phy/smsc.c
>> +++ b/drivers/net/phy/smsc.c
>> @@ -264,6 +264,29 @@ static struct phy_driver smsc_phy_driver[] = {
>>  	.resume		= genphy_resume,
>>  
>>  	.driver		= { .owner = THIS_MODULE, }
>> +}, {
>> +	.phy_id		= 0x0007c110,
>> +	.phy_id_mask	= 0xfffffff0,
>> +	.name		= "SMSC LAN8740",
>> +
>> +	.features	= (PHY_BASIC_FEATURES | SUPPORTED_Pause
>> +				| SUPPORTED_Asym_Pause),
>> +	.flags		= PHY_HAS_INTERRUPT | PHY_HAS_MAGICANEG,
>> +
>> +	/* basic functions */
>> +	.config_aneg	= genphy_config_aneg,
>> +	.read_status	= lan87xx_read_status,
>> +	.config_init	= smsc_phy_config_init,
>> +	.soft_reset	= smsc_phy_reset,
>> +
>> +	/* IRQ related */
>> +	.ack_interrupt	= smsc_phy_ack_interrupt,
>> +	.config_intr	= smsc_phy_config_intr,
>> +
>> +	.suspend	= genphy_suspend,
>> +	.resume		= genphy_resume,
>> +
>> +	.driver		= { .owner = THIS_MODULE, }
>>  } };
> 
> Hi Joshua
> 
> You should remove this .driver line. The core sets it now.
> 
>     Andrew
> 

Got it.  I'll apply against net-next.

Thanks,
Josh
