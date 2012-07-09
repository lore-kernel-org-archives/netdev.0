From: Heiko Schocher <hs-ynQEQJNshbs@public.gmane.org>
Subject: Re: [PATCH v5 4/7] ARM: davinci: net: davinci_emac: add OF support
Date: Mon, 09 Jul 2012 10:25:28 +0200
Message-ID: <4FFA9578.1070400@denx.de>
References: <1338373143-7467-1-git-send-email-hs@denx.de>
 <1338373143-7467-5-git-send-email-hs@denx.de> <4FF998A7.50309@ti.com>
Reply-To: hs-ynQEQJNshbs@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org, Wolfgang Denk <wd-ynQEQJNshbs@public.gmane.org>,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 Anatoly Sivov <mm05-JGs/UdohzUI@public.gmane.org>, linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-reply-to: <4FF998A7.50309-l0cyMroinI0@public.gmane.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

Hello Sekhar,

On 08.07.2012 16:26, Sekhar Nori wrote:
[...]
> On 5/30/2012 3:49 PM, Heiko Schocher wrote:
>> add of support for the davinci_emac driver.
>>
>> Signed-off-by: Heiko Schocher<hs-ynQEQJNshbs@public.gmane.org>
>> Cc: davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org
>> Cc: linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
>> Cc: devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
>> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
>> Cc: Grant Likely<grant.likely-s3s/WqlpOiPyB63q8FvJNQ@public.gmane.org>
>> Cc: Sekhar Nori<nsekhar-l0cyMroinI0@public.gmane.org>
>> Cc: Wolfgang Denk<wd-ynQEQJNshbs@public.gmane.org>
>> Cc: Anatoly Sivov<mm05-JGs/UdohzUI@public.gmane.org>
>>
>> ---
>
>> +#ifdef CONFIG_OF
>> +static struct emac_platform_data
>> +	*davinci_emac_of_get_pdata(struct platform_device *pdev,
>> +	struct emac_priv *priv)
>> +{
>> +	struct device_node *np;
>> +	struct emac_platform_data *pdata = NULL;
>> +	const u8 *mac_addr;
>> +	u32 data;
>> +	int ret;
>> +
>> +	pdata = pdev->dev.platform_data;
>> +	if (!pdata) {
>> +		pdata = devm_kzalloc(&pdev->dev, sizeof(*pdata), GFP_KERNEL);
>> +		if (!pdata)
>> +			goto nodata;
>> +	}
>> +
>> +	np = pdev->dev.of_node;
>> +	if (!np)
>> +		goto nodata;
>> +	else
>> +		pdata->version = EMAC_VERSION_2;
>> +
>> +	mac_addr = of_get_mac_address(np);
>> +	if (mac_addr)
>> +		memcpy(pdata->mac_addr, mac_addr, ETH_ALEN);
>
> I suspect that even in the DT case, many boards will continue to
> read mac address from on-board EEPROMs or from an on-chip eFUSE.
> To take care of such cases, I propose use mac address in DT data
> only if no valid address is passed through platform data. The
> attached patch does this change.

Ok, understand. I am fine with this.

> If you are OK with this modification, can you please merge it and
> repost just this patch for review? Please CC David Miller
> (davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org) on your next post as he is the netdev maintainer
> and this patch needs to be merged through him or at least needs his ack.

Merged, done.

> With this modification, you can add my:
>
> Acked-by: Sekhar Nori<nsekhar-l0cyMroinI0@public.gmane.org>

Ok, thanks. Post this patch soon, if I am finished with testing this
change.

bye,
Heiko
-- 
DENX Software Engineering GmbH,     MD: Wolfgang Denk & Detlev Zundel
HRB 165235 Munich, Office: Kirchenstr.5, D-82194 Groebenzell, Germany
