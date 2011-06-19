From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH 2/3] net/fec: add device tree support
Date: Sun, 19 Jun 2011 12:43:30 -0600
Message-ID: <BANLkTinbPGMyBxK+zo6ZtFhisSSkU7daYA@mail.gmail.com>
References: <1308410354-21387-1-git-send-email-shawn.guo@linaro.org>
 <1308410354-21387-3-git-send-email-shawn.guo@linaro.org> <4DFDDFF4.8000305@snapgear.com>
 <201106191411.32137.arnd@arndb.de> <4DFE111B.8010001@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnd Bergmann <arnd@arndb.de>, Shawn Guo <shawn.guo@linaro.org>,
	linux-arm-kernel@lists.infradead.org,
	Greg Ungerer <gerg@snapgear.com>, patches@linaro.org,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	Jason Liu <jason.hui@linaro.org>, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Rob Herring <robherring2@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4DFE111B.8010001@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Jun 19, 2011 at 9:09 AM, Rob Herring <robherring2@gmail.com> wr=
ote:
> On 06/19/2011 07:11 AM, Arnd Bergmann wrote:
>> On Sunday 19 June 2011 13:39:32 Greg Ungerer wrote:
>>>> +#ifdef CONFIG_OF
>>>> +static const struct of_device_id fec_dt_ids[] =3D {
>>>> + =A0 =A0 { .compatible =3D "fsl,fec", .data =3D&fec_devtype[0], }=
,
>>>> + =A0 =A0 {},
>>>> +};
>>>> +
>>>> +static const struct of_device_id *
>>>> +fec_get_of_device_id(struct platform_device *pdev)
>>>> +{
>>>> + =A0 =A0 return of_match_device(fec_dt_ids,&pdev->dev);
>>>> +}
>>>> +#else
>>>> +#define fec_dt_ids NULL
>>>> +static inline struct of_device_id *
>>>> +fec_get_of_device_id(struct platform_device *pdev)
>>>> +{
>>>> + =A0 =A0 return NULL;
>>>> +}
>>>> +#endif
>>>> +
>>>> =A0 static unsigned char macaddr[ETH_ALEN];
>>>> =A0 module_param_array(macaddr, byte, NULL, 0);
>>>> =A0 MODULE_PARM_DESC(macaddr, "FEC Ethernet MAC address");
>>>> @@ -1363,6 +1385,11 @@ fec_probe(struct platform_device *pdev)
>>>> =A0 =A0 =A0 struct net_device *ndev;
>>>> =A0 =A0 =A0 int i, irq, ret =3D 0;
>>>> =A0 =A0 =A0 struct resource *r;
>>>> + =A0 =A0 const struct of_device_id *of_id;
>>>> +
>>>> + =A0 =A0 of_id =3D fec_get_of_device_id(pdev);
>>>
>>> fec_get_of_device_id() is defined inside of "#ifdef CONFIG_OF". Thi=
s
>>> use of it will break compilation when this is not defined.
>>>
>>
>>
>> Why? Note the #else path defining an empty function.
>>
>
> None of this is necessary in the first place. Just call of_match_devi=
ce
> directly. There is already an empty function to return NULL when
> CONFIG_OF is not defined.

Heh, right you are.  I should have caught on to that.  :-)

g.
