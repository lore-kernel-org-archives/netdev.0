From: Christophe Leroy <christophe.leroy@c-s.fr>
Subject: Re: [PATCH] net: phy: micrel: remove suspend/resume
Date: Wed, 24 Aug 2016 16:14:01 +0200
Message-ID: <8b2ab09d-761f-080b-8264-4464f9afc442@c-s.fr>
References: <20160823111344.25FF41A2459@localhost.localdomain>
 <2ee9441d-1b3b-de6d-691d-b615c04c69d0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        xander.huff@ni.com, brad.mouring@ni.com, nathan.sullivan@ni.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2ee9441d-1b3b-de6d-691d-b615c04c69d0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Le 23/08/2016 à 21:03, Florian Fainelli a écrit :
> +others,
>
> On 08/23/2016 04:13 AM, Christophe Leroy wrote:
>> In ERRATA DS80000700A dated 05 May 2016, Microship recommends to
>> not use software power down mode on KSZ8041 family.
>
> s/Microship/Microchip/
>
>> They say they have no plan to fix this ERRATA in future releases.
>
> The errata applies to specific revisions, is this revision present in
> the lower 4 bits of the MII_PHYSID2 register such that it could be used
> to key the disabling of the power down?

It doesn't seem clear to me how this could/should be handled.

According to the documentation, all variants have the same ID 0x0022151x 
with revision x. A3 has ID 0x00221512 and A4 has 0x00221513.
According to the doc, the KSZ8041RNLI should has same ID. But according 
to micrel driver, it has ID 0x00221537. And the buggy revision of that 
one is rev A. Is it what the 7 means ?

The ERRATA applies to KSZ8041NL revision A4 and to KSZ8041NL-AM revision 
A3. My understanding it that both variants have ID 0x0022151x, ie 
KSZ8041NL-AM revision A3 has ID 0x00221512 and KSZ8041NL revision A4 has 
ID 0x00221513. But KSZ8041NL revision A3 also has ID 0x00221512 and the 
ERRATA doesn't apply to it.

So what can be done really ? Only apply the fix to ID 0x00221513 (which 
is what I need as I have KSZ8041NL revision A4 on my boards) ? Or apply 
it for all KSZ8041 and KSZ8041RNLI to be on the safe side ?

Christophe


>
>>
>> http://ww1.microchip.com/downloads/en/DeviceDoc/80000700A.pdf
>>
>> Signed-off-by: Christophe Leroy <christophe.leroy@c-s.fr>
>> ---
>>  drivers/net/phy/micrel.c | 4 ----
>>  1 file changed, 4 deletions(-)
>>
>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>> index 053e879..f456c55 100644
>> --- a/drivers/net/phy/micrel.c
>> +++ b/drivers/net/phy/micrel.c
>> @@ -837,8 +837,6 @@ static struct phy_driver ksphy_driver[] = {
>>  	.get_sset_count = kszphy_get_sset_count,
>>  	.get_strings	= kszphy_get_strings,
>>  	.get_stats	= kszphy_get_stats,
>> -	.suspend	= genphy_suspend,
>> -	.resume		= genphy_resume,
>>  }, {
>>  	.phy_id		= PHY_ID_KSZ8041RNLI,
>>  	.phy_id_mask	= MICREL_PHY_ID_MASK,
>> @@ -856,8 +854,6 @@ static struct phy_driver ksphy_driver[] = {
>>  	.get_sset_count = kszphy_get_sset_count,
>>  	.get_strings	= kszphy_get_strings,
>>  	.get_stats	= kszphy_get_stats,
>> -	.suspend	= genphy_suspend,
>> -	.resume		= genphy_resume,
>>  }, {
>>  	.phy_id		= PHY_ID_KSZ8051,
>>  	.phy_id_mask	= MICREL_PHY_ID_MASK,
>>
>
>
