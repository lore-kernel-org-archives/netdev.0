From: Alexander Graf <agraf@suse.de>
Subject: Re: [PATCH] phy dp83867: depend on CONFIG_OF_MDIO
Date: Mon, 16 May 2016 19:57:59 +0200
Message-ID: <202f4843-bf2f-8131-cea8-923ba3766fc3@suse.de>
References: <1463398095-123269-1-git-send-email-agraf@suse.de>
 <5739CD4C.7020208@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, michal.simek@xilinx.com
To: Dan Murphy <dmurphy@ti.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5739CD4C.7020208@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dan,

On 16.05.16 15:38, Dan Murphy wrote:
> Alexander
> 
> On 05/16/2016 06:28 AM, Alexander Graf wrote:
>> The DP83867 phy driver doesn't actually work when CONFIG_OF_MDIO isn't enabled.
>> It simply passes the device tree test, but leaves all internal configuration
>> initialized at 0. Then it configures the phy with those values and renders a
>> previously working configuration useless.
>>
>> This patch makes sure that we only build the DP83867 phy code when
>> CONFIG_OF_MDIO is set, to not run into that problem.
>>
>> Signed-off-by: Alexander Graf <agraf@suse.de>
>> ---
>>  drivers/net/phy/Kconfig   | 1 +
>>  drivers/net/phy/dp83867.c | 7 -------
>>  2 files changed, 1 insertion(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/phy/Kconfig b/drivers/net/phy/Kconfig
>> index 6dad9a9..4265ad5 100644
>> --- a/drivers/net/phy/Kconfig
>> +++ b/drivers/net/phy/Kconfig
>> @@ -148,6 +148,7 @@ config DP83848_PHY
>>  
>>  config DP83867_PHY
>>  	tristate "Drivers for Texas Instruments DP83867 Gigabit PHY"
>> +	depends on OF_MDIO
>>  	---help---
>>  	  Currently supports the DP83867 PHY.
>>  
>> diff --git a/drivers/net/phy/dp83867.c b/drivers/net/phy/dp83867.c
>> index 2afa61b..ff867ba 100644
>> --- a/drivers/net/phy/dp83867.c
>> +++ b/drivers/net/phy/dp83867.c
>> @@ -99,7 +99,6 @@ static int dp83867_config_intr(struct phy_device *phydev)
>>  	return phy_write(phydev, MII_DP83867_MICR, micr_status);
>>  }
>>  
>> -#ifdef CONFIG_OF_MDIO
>>  static int dp83867_of_init(struct phy_device *phydev)
>>  {
>>  	struct dp83867_private *dp83867 = phydev->priv;
>> @@ -123,12 +122,6 @@ static int dp83867_of_init(struct phy_device *phydev)
>>  	return of_property_read_u32(of_node, "ti,fifo-depth",
>>  				   &dp83867->fifo_depth);
>>  }
>> -#else
>> -static int dp83867_of_init(struct phy_device *phydev)
>> -{
>> -	return 0;
>> -}
>> -#endif /* CONFIG_OF_MDIO */
>>  
>>  static int dp83867_config_init(struct phy_device *phydev)
>>  {
> I don't think we want this to depend solely on OF_MDIO.
> 
> The #else case should probably be coded to look at platform data, if
> it exists.  I don't have any boards that still used platform data to test this
> out so I did not feel comfortable adding code I could not test.

Since there was no code to look at platform data, those boards would be
broken just as well today, no? So at the end of the day, this change
should be no regression for them.


Alex
