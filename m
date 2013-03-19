From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v6] net: sh_eth: Add support of device tree probe
Date: Tue, 19 Mar 2013 20:29:46 +0400
Message-ID: <5148927A.8070409@cogentembedded.com>
References: <1363675196-8940-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <51486699.6000908@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	magnus.damm@gmail.com, kda@linux-powerpc.org,
	horms+renesas@verge.net.au, mark.rutland@arm.com,
	grant.likely@secretlab.ca
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f44.google.com ([209.85.215.44]:44409 "EHLO
	mail-la0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756246Ab3CSQag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Mar 2013 12:30:36 -0400
Received: by mail-la0-f44.google.com with SMTP id eb20so1316332lab.17
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 09:30:34 -0700 (PDT)
In-Reply-To: <51486699.6000908@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 19-03-2013 17:22, Sergei Shtylyov wrote:

>> This adds support of device tree probe for Renesas sh-ether driver.

>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

>> V6: - Add renesas,sh-eth-gigabit, renesas,sh-eth-sh4 and
>>        renesas,sh-eth-sh3-sh2 to compatible string.
>>     - Remove sh-eth,register-type. This is supplemented by the
>>        compatible string.
>>      - Use the of_property_read_bool instead of of_find_property.
>>      - Add sanity chheck for of_property_read_u32.
>>      - Update document.
>> V5: - Rewrite sh_eth_parse_dt().
>>        Remove of_device_is_available() and CONFIG_OF from support OF
>>        checking function and re-add empty sh_eth_parse_dt().
>>      - Add CONFIG_PM to definition of dev_pm_ops.
>>     - Add CONFIG_OF to definition of of_device_id.
>> V4: - Remove empty sh_eth_parse_dt().
>> V3: - Remove empty sh_eth_parse_dt().
>> V3: - Removed sentnece of "needs-init" from document.
>> V2: - Removed ether_setup().
>>      - Fixed typo from "sh-etn" to "sh-eth".
>>     - Removed "needs-init" and sh-eth,endian from definition of DT.
>>     - Changed "sh-eth,edmac-endian" instead of "sh-eth,edmac-big-end=
ain"
>>       in definition of DT.

    The version history is usually "hidded" under -- tear line.

>> ---
>>   Documentation/devicetree/bindings/net/sh_ether.txt |   48 +++++++
>>   drivers/net/ethernet/renesas/sh_eth.c              |  145
>> ++++++++++++++++----
>>   2 files changed, 168 insertions(+), 25 deletions(-)
>>   create mode 100644 Documentation/devicetree/bindings/net/sh_ether.=
txt

[...]

>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c
>> b/drivers/net/ethernet/renesas/sh_eth.c
>> index 7a6471d..d9df68e 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
[...]
>> @@ -2391,12 +2451,33 @@ static int sh_eth_drv_probe(struct platform_=
device
>> *pdev)
>>           goto out_release;
>>       }
>>
>> +    if (np) {
>> +        pd =3D sh_eth_parse_dt(&pdev->dev, ndev, np);
>> +        if (pdev->dev.platform_data && pd) {
>> +            struct sh_eth_plat_data *tmp =3D
>> +                pdev->dev.platform_data;
>> +            pd->set_mdio_gate =3D tmp->set_mdio_gate;
>> +            pd->needs_init =3D tmp->needs_init;

>     OK, so we can't fully convert this driver to the device tree due =
to
> procedural platform data. I then would advice just using OF_DEV_AUXDA=
TA() in
> the platform data instead of trying to convert the driver to device t=
ree.

    I meant to type "=EFnstead of trying to convert the paltform data t=
o device=20
tree".

>> @@ -2515,17 +2595,32 @@ static int sh_eth_runtime_nop(struct device =
*dev)
[...]
>> +
>> +#ifdef CONFIG_OF
>> +static const struct of_device_id sh_eth_match[] =3D {
>> +    { .compatible =3D "renesas,sh-eth-gigabit", },
>> +    { .compatible =3D "renesas,sh-eth-sh4", },
>> +    { .compatible =3D "renesas,sh-eth-sh3-sh2", },

>     Biut this is not really enough: the driver supports much more var=
iations
> of the SH and ARM SoCs all of which have difference not only in regis=
ter
> layout but also in the registers bits or even presence of the whole r=
egister
> blocks. All this IMO should be reflected in the different values of t=
he
> compatible "property". BTW, it seems another register layout and inst=
ance

    I forgot to type istance of what: 'sh_eth_my_cpu_data'.

> needs to be added for the R-Car SoCs (instead of the current ugly hac=
k).

WBR, Sergei
