From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] of_mdio: fix phy interrupt passing
Date: Tue, 18 Feb 2014 18:13:17 -0500 (EST)
Message-ID: <20140218.181317.1712776234149210938.davem@davemloft.net>
References: <1392725818-558-1-git-send-email-ben.dooks@codethink.co.uk>
	<20140218161551.44A52C40517@trevor.secretlab.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben.dooks@codethink.co.uk, linux-kernel@lists.codethink.co.uk,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
To: grant.likely@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140218161551.44A52C40517@trevor.secretlab.ca>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grant Likely <grant.likely@linaro.org>
Date: Tue, 18 Feb 2014 16:15:51 +0000

> On Tue, 18 Feb 2014 12:16:58 +0000, Ben Dooks <ben.dooks@codethink.co.uk> wrote:
>> The of_mdiobus_register_phy() is not setting phy->irq thus causing
>> some drivers to incorrectly assume that the PHY does not have an
>> IRQ associated with it. Not only do some drivers report no IRQ
>> they do not install an interrupt handler for the PHY.
>> 
>> Simplify the code setting irq and set the phy->irq at the same
>> time so that we cover the following issues, which should cover
>> all the cases the code will find:
>> 
>> - Set phy->irq if node has irq property and mdio->irq is NULL
>> - Set phy->irq if node has no irq and mdio->irq is not NULL
>> - Leave phy->irq as PHY_POLL default if none of the above
>> 
>> This fixes the issue:
>>  net eth0: attached PHY 1 (IRQ -1) to driver Micrel KSZ8041RNLI
>> 
>> to the correct:
>>  net eth0: attached PHY 1 (IRQ 416) to driver Micrel KSZ8041RNLI
>> 
>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
> 
> Looks okay to me
> 
> Reviewed-by: Grant Likely <grant.likely@linaro.org>

Applied, thanks.
