From: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH RESEND net-next 4/9] net: systemport: use the new fixed
 PHY helpers
Date: Wed, 21 May 2014 15:02:42 -0700
Message-ID: <CAGVrzcbBQFhw-dUh+tFm8H5m9-fmVgutChS8wUG-F6sTBoRq-g@mail.gmail.com>
References: <1400708331-18088-1-git-send-email-f.fainelli@gmail.com>
 <1400708331-18088-5-git-send-email-f.fainelli@gmail.com> <537D20EA.1000305@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Pantelis Antoniou <pantelis.antoniou-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Vitaly Bordug <vbordug-hkdhdckH98+B+jHODAdFcQ@public.gmane.org>,
	Li Yang <leoli-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Thomas Petazzoni <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
	Aida Mynzhasova <aida.mynzhasova-Fmhy8gsqeTEvJsYlp49lxw@public.gmane.org>,
	Richard Cochran <richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Claudiu Manoil <claudiu.manoil-KZfg59tc24xl57MIdRCFDg@public.gmane.org>,
	"open list:OPEN FIRMWARE AND..." <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:LINUX FOR POWERPC..." <linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <537D20EA.1000305-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

2014-05-21 14:55 GMT-07:00 Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>:
> On 05/22/2014 01:38 AM, Florian Fainelli wrote:
>
>> of_phy_connect_fixed_link() is becoming obsolete, and also required
>> platform code to register the fixed PHYs at the specified addresses for
>> those to be usable. Get rid of it and use the new of_phy_is_fixed_link()
>> plus of_phy_register_fixed_link() helpers to transition over the new
>> scheme.
>
>
>> Signed-off-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> ---
>>   drivers/net/ethernet/broadcom/bcmsysport.c | 17 +++++++++++++++--
>>   drivers/net/ethernet/broadcom/bcmsysport.h |  1 +
>>   2 files changed, 16 insertions(+), 2 deletions(-)
>
>
>> diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c
>> b/drivers/net/ethernet/broadcom/bcmsysport.c
>> index d40c5b969e9e..dc708a888f80 100644
>> --- a/drivers/net/ethernet/broadcom/bcmsysport.c
>> +++ b/drivers/net/ethernet/broadcom/bcmsysport.c
>> @@ -1327,8 +1327,8 @@ static int bcm_sysport_open(struct net_device *dev)
>>         /* Read CRC forward */
>>         priv->crc_fwd = !!(umac_readl(priv, UMAC_CMD) & CMD_CRC_FWD);
>>
>> -       priv->phydev = of_phy_connect_fixed_link(dev,
>> bcm_sysport_adj_link,
>> -
>> priv->phy_interface);
>> +       priv->phydev = of_phy_connect(dev, priv->phy_dn,
>> bcm_sysport_adj_link,
>> +                                       0, priv->phy_interface);
>
>
>    The continuation line should start on the next character after ( on the
> above line, according to the networking coding style.

Unless I am once again not following the coding style, the patch in
patchwork has this correctly, and so does my file locally:

http://patchwork.ozlabs.org/patch/351323/
-- 
Florian
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
