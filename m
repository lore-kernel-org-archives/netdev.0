From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [net-next 1/4] phy: add the EEE support and the way to access
 to the MMD regs
Date: Thu, 08 Mar 2012 15:54:25 +0100
Message-ID: <4F58C821.3040104@st.com>
References: <4F4E4D4B.3040909@st.com>  <1331022494-12891-1-git-send-email-peppe.cavallaro@st.com>  <1331022494-12891-2-git-send-email-peppe.cavallaro@st.com>  <1331052913.2333.16.camel@bwh-desktop> <1331053557.2333.19.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	rayagond@vayavyalabs.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog110.obsmtp.com ([207.126.144.129]:57261 "EHLO
	eu1sys200aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752255Ab2CHOzT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2012 09:55:19 -0500
In-Reply-To: <1331053557.2333.19.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Ben

thanks for your review and sorry for my delay.

On 3/6/2012 6:05 PM, Ben Hutchings wrote:
> On Tue, 2012-03-06 at 16:55 +0000, Ben Hutchings wrote:
>> On Tue, 2012-03-06 at 09:28 +0100, Giuseppe CAVALLARO wrote:
>>> This patch adds the initial support for the Energy-Efficient
>>> Ethernet (EEE). It has been tested on IC+101G device on ST STB.
>>>
>>> To support the EEE we have to access to the MMD registers 3.20 and
>>> 3.60/61. So I added two new functions to read/write the MMD
>>> registers (clause 45)
>>>
>>> The upper-layer will invoke the phy_check_eee to properly check
>>> if the EEE is supported by the PHYs.
>>>
>>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>>> ---
>>>  drivers/net/phy/phy_device.c |  136 ++++++++++++++++++++++++++++++++++++++++++
>>>  include/linux/mdio.h         |    5 ++
>>>  include/linux/mii.h          |   11 ++++
>>>  include/linux/phy.h          |    3 +
>>>  4 files changed, 155 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
>>> index f320f46..c269492e 100644
>>> --- a/drivers/net/phy/phy_device.c
>>> +++ b/drivers/net/phy/phy_device.c
>> [...]
>>> @@ -898,6 +899,141 @@ int genphy_resume(struct phy_device *phydev)
>>>  }
>>>  EXPORT_SYMBOL(genphy_resume);
>>>  
>>> +static inline void mmd_phy_cl45(struct mii_bus *bus, int prtad, int devad,
>>> +				int addr)
>> [...]
>>> +/**
>>> + * read_phy_mmd - reads data from the MMC register (clause 22 to access to
>>> + * clause 45)
>> [...]
>>> +/**
>>> + * write_phy_mmd - writes data to the MMC register (clause 22 to access to
>>> + * clause 45)
>>
>> These names need to be changed as phylib also supports (or is intended
>> to support) real clause 45 PHYs.


What do you suggest? Do I have to rename these functions for example as?

write_phy_mmd  ---->    phy_write_mmd_cl45
read_phy_mmd   ---->    phy_read_mmd_cl45

I've also another doubt. I put this code in phy_device.c. Is it correct?

Maybe, it could be better have it in phy.c? What do you think?

>> [...]
>>> diff --git a/include/linux/mdio.h b/include/linux/mdio.h
>>> index dfb9479..a2dfe86 100644
>>> --- a/include/linux/mdio.h
>>> +++ b/include/linux/mdio.h
>>> @@ -43,7 +43,11 @@
>>>  #define MDIO_PKGID2		15
>>>  #define MDIO_AN_ADVERTISE	16	/* AN advertising (base page) */
>>>  #define MDIO_AN_LPA		19	/* AN LP abilities (base page) */
>>> +#define MDIO_EEE_CAP		20	/* EEE Capability register */
>>> +#define MDIO_EEE_WK_ERR		22	/* EEE wake error counter */
>>>  #define MDIO_PHYXS_LNSTAT	24	/* PHY XGXS lane state */
>>> +#define MDIO_EEE_ADV		60	/* EEE advertisement */
>>> +#define MDIO_EEE_PART_LINK	61	/* EEE link partner ability */
>>>  
>>>  /* Media-dependent registers. */
>>>  #define MDIO_PMA_10GBT_SWAPPOL	130	/* 10GBASE-T pair swap & polarity */
>>
>> The convention I tried to set here was that register numbers defined for
>> only one MMD are named beginning with MDIO_<mmd>_.  I also used 'LP' for
>> link partner and 'ABLE' for capability/ability.
>>
>> So for consistency I think those should be named MDIO_PCS_EEE_ABLE,
>> MDIO_PCS_EEE_WK_ERR, MDIO_AN_EEE_ADV, MDIO_AN_EEE_LPABLE.
> [...]

Perfect, I'll adopt this name convention.

> 
> And note we already have MDIO_AN_EEE_ADV under 'Media-dependent
> registers'.  I think that may be the wrong section so feel free to move
> it up to 'Generic MDIO registers', but don't make two definitions.

This is my fault and I'll fix it at once, sorry!

Peppe

> 
> Ben.
> 
