From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH regression] net: phy: fix initialization (config_init)
 for Marvel 88E1116R PHYs
Date: Wed, 02 Apr 2014 16:07:07 +0400
Message-ID: <533BFD6B.7050503@cogentembedded.com>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <533BF9CE.3050302@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Florian Fainelli <f.fainelli@gmail.com>,
	Michal Simek <michal.simek@xilinx.com>, stable@vger.kernel.org
To: Alexander Holler <holler@ahsoftware.de>,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <533BF9CE.3050302@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02-04-2014 15:51, Sergei Shtylyov wrote:

>> Commit 7cd1463664c2a15721ff4ccfb61d4d970815cb3d (introduced with 3.14)
>> changed the initialization of the mv643xx_eth driver to use phy_init_hw()
>> to reset the PHY. Unfortunately the initialization for the 88E1116R PHY
>> was broken such, that it used mdelay() instead of really waiting for a
>> reset to finish.

>> The effect was that the ethernet on my Kirkwood 88F6281 based device didn't
>> come up anymore (no carrier).

>> Fix this by waiting for a reset to finish before proceeding further.

>> Signed-off-by: Alexander Holler <holler@ahsoftware.de>

>> Cc: Michal Simek <michal.simek@xilinx.com>
>> Cc: Florian Fainelli <f.fainelli@gmail.com>
>> Cc: <stable@vger.kernel.org>
>> ---
>>   drivers/net/phy/marvell.c | 8 ++++++--
>>   1 file changed, 6 insertions(+), 2 deletions(-)

>> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
>> index bd37e45..5b84808 100644
>> --- a/drivers/net/phy/marvell.c
>> +++ b/drivers/net/phy/marvell.c
[...]
>> @@ -429,7 +431,9 @@ static int m88e1116r_config_init(struct phy_device *phydev)
>>       if (err < 0)
>>           return err;
>>
>> -    mdelay(500);
>> +    do
>> +        temp = phy_read(phydev, MII_BMCR);
>> +    while (temp & BMCR_RESET);

>     Not clear why it's necessary to reset one more time... Also, tight loop
> without a timeout (0.5 sec, specified by IEEE 802.3) doesn't look good. The
> comment above phy_poll_reset() suggests that it could be used in the PHY
> drivers as well. Florian?

    Ah, I was looking at Linus' tree, not net-next.git, and hadn't read 
Florian's replies before commenting on this...

WBR, Sergei
