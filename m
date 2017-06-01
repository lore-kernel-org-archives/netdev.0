From: Andy Duan <fugang.duan-3arQi8VN3Tc@public.gmane.org>
Subject: RE: [PATCH v2] net: fec: add post PHY reset delay DT property
Date: Thu, 1 Jun 2017 01:39:18 +0000
Message-ID: <AM4PR0401MB226073F4A403F31FA0FF2BE0FFF60@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <20170523094808.11102-1-quentin.schulz@free-electrons.com>
 <20170531164416.ka3hk6a2lybrlngd@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "mark.rutland-5wv7dgnIgG8@public.gmane.org" <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org"
        <thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
To: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170531164416.ka3hk6a2lybrlngd@rob-hp-laptop>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> Sent: Thursday, June 01, 2017 12:44 AM
>On Tue, May 23, 2017 at 11:48:08AM +0200, Quentin Schulz wrote:
>> Some PHY require to wait for a bit after the reset GPIO has been
>> toggled. This adds support for the DT property `phy-reset-post-delay`
>> which gives the delay in milliseconds to wait after reset.
>>
>> If the DT property is not given, no delay is observed. Post reset
>> delay greater than 1000ms are invalid.
>>
>> Signed-off-by: Quentin Schulz <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>
>> ---
>>
>> v2:
>>   - return -EINVAL when phy-reset-post-delay is greater than 1000ms
>>   instead of defaulting to 1ms,
>>   - remove `default to 1ms` when phy-reset-post-delay > 1000Ms from DT
>>   binding doc and commit log,
>>   - move phy-reset-post-delay property reading before
>>   devm_gpio_request_one(),
>>
>>  Documentation/devicetree/bindings/net/fsl-fec.txt |  4 ++++
>>  drivers/net/ethernet/freescale/fec_main.c         | 16 +++++++++++++++-
>>  2 files changed, 19 insertions(+), 1 deletion(-)
>>
>> diff --git a/Documentation/devicetree/bindings/net/fsl-fec.txt
>> b/Documentation/devicetree/bindings/net/fsl-fec.txt
>> index a1e3693cca16..6f55bdd52f8a 100644
>> --- a/Documentation/devicetree/bindings/net/fsl-fec.txt
>> +++ b/Documentation/devicetree/bindings/net/fsl-fec.txt
>> @@ -15,6 +15,10 @@ Optional properties:
>>  - phy-reset-active-high : If present then the reset sequence using the =
GPIO
>>    specified in the "phy-reset-gpios" property is reversed (H=3Dreset st=
ate,
>>    L=3Doperation state).
>> +- phy-reset-post-delay : Post reset delay in milliseconds. If present
>> +then
>
>This needs unit suffix minimally. It should also have a vendor prefix or b=
e
>made generic.
>
>But really, this is a property of the phy and should be in the phy node as
>should phy-reset-gpios, phy-reset-active-high, phy-supply, etc.
>
Yes, it is better to make it general.
Last year, Uwe Kleine-K=F6nig's patch "Commit da47b4572056 ("phy: add suppo=
rt for a reset-gpio specification")" did this, but it was reverted by commi=
t 948350140ef0 (Revert "phy: add support for a reset-gpio specification"). =
 And in all phy device driver, only at803x.c add the gpio reset in currentl=
y.=20
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
