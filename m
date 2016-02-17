From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2 2/5] net: phy: dp83848: Add PHY ID for TI version of
 DP83848C
Date: Wed, 17 Feb 2016 15:44:35 -0800
Message-ID: <56C505E3.3020104@gmail.com>
References: <1454867241-20928-1-git-send-email-afd@ti.com>
 <1454867241-20928-3-git-send-email-afd@ti.com> <56C50443.8060802@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Andrew F. Davis" <afd@ti.com>,
	"David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56C50443.8060802@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 17/02/2016 15:37, Andrew F. Davis wrote:
> On 02/07/2016 11:47 AM, Andrew F. Davis wrote:
>> After acquiring National Semiconductor, TI appears to have
>> changed the Vendor Model Number for the DP83848C PHYs,
>> add this new ID to supported IDs.
>>
>> Signed-off-by: Andrew F. Davis <afd@ti.com>
>> ---
>>   drivers/net/phy/dp83848.c | 9 ++++++---
>>   1 file changed, 6 insertions(+), 3 deletions(-)
>>
>> diff --git a/drivers/net/phy/dp83848.c b/drivers/net/phy/dp83848.c
>> index 4e78f54..d4686d5f 100644
>> --- a/drivers/net/phy/dp83848.c
>> +++ b/drivers/net/phy/dp83848.c
>> @@ -16,7 +16,8 @@
>>   #include <linux/module.h>
>>   #include <linux/phy.h>
>>
>> -#define DP83848_PHY_ID            0x20005c90
>> +#define TI_DP83848C_PHY_ID        0x20005ca0
>> +#define NS_DP83848C_PHY_ID        0x20005c90
>>
>>   /* Registers */
>>   #define DP83848_MICR            0x11
>> @@ -65,7 +66,8 @@ static int dp83848_config_intr(struct phy_device
>> *phydev)
>>   }
>>
>>   static struct mdio_device_id __maybe_unused dp83848_tbl[] = {
>> -    { DP83848_PHY_ID, 0xfffffff0 },
>> +    { TI_DP83848C_PHY_ID, 0xfffffff0 },
>> +    { NS_DP83848C_PHY_ID, 0xfffffff0 },
>>       { }
>>   };
>>   MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
>> @@ -91,7 +93,8 @@ MODULE_DEVICE_TABLE(mdio, dp83848_tbl);
>>       }
>>
>>   static struct phy_driver dp83848_driver[] = {
>> -    DP83848_PHY_DRIVER(DP83848_PHY_ID, "TI DP83848 10/100 Mbps PHY"),
>> +    DP83848_PHY_DRIVER(TI_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps
>> PHY"),
>> +    DP83848_PHY_DRIVER(NS_DP83848C_PHY_ID, "TI DP83848C 10/100 Mbps
>> PHY"),
> 
> This seems to be causing a warning about duplicate file names (driver
> name in
> sysfs), so the bottom one can probably s/TI/NS, can this be changed in-tree
> before the merge or should I submit a patch?

Once the patches are merged by David in his tree, you will need to
provide an incremental patch to fix the problem. I had not noticed the
duplicate name either here, but it sounds like you should indeed fix it.

Thanks!
