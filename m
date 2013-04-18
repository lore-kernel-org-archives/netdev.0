From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v6] net: sh_eth: Add support of device tree probe
Date: Thu, 18 Apr 2013 18:04:27 +0400
Message-ID: <516FFD6B.8020901@cogentembedded.com>
References: <1363675196-8940-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com> <51486699.6000908@cogentembedded.com> <514AB0CB.2030808@renesas.com> <516B0C59.3050207@cogentembedded.com> <516B6340.9090604@renesas.com> <516C4C70.7050802@cogentembedded.com> <516E551A.1030804@renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	magnus.damm@gmail.com, kda@linux-powerpc.org,
	horms+renesas@verge.net.au, mark.rutland@arm.com,
	grant.likely@secretlab.ca
To: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f48.google.com ([209.85.215.48]:48703 "EHLO
	mail-la0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964949Ab3DROFh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 10:05:37 -0400
Received: by mail-la0-f48.google.com with SMTP id fq13so1464568lab.7
        for <netdev@vger.kernel.org>; Thu, 18 Apr 2013 07:05:35 -0700 (PDT)
In-Reply-To: <516E551A.1030804@renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 17-04-2013 11:54, Nobuhiro Iwamatsu wrote:

>>>>>>> This adds support of device tree probe for Renesas sh-ether driver.

>>>>>>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>

[...]

>>>>>>> @@ -2391,12 +2451,33 @@ static int sh_eth_drv_probe(struct platform_device
>>>>>>> *pdev)
>>>>>>> goto out_release;
>>>>>>> }
>>>>>>>
>>>>>>> + if (np) {
>>>>>>> + pd = sh_eth_parse_dt(&pdev->dev, ndev, np);
>>>>>>> + if (pdev->dev.platform_data && pd) {
>>>>>>> + struct sh_eth_plat_data *tmp =
>>>>>>> + pdev->dev.platform_data;
>>>>>>> + pd->set_mdio_gate = tmp->set_mdio_gate;
>>>>>>> + pd->needs_init = tmp->needs_init;

>>>>>> OK, so we can't fully convert this driver to the device tree due to
>>>>>> procedural platform data.

>>>>> > I then would advice just using OF_DEV_AUXDATA() in the platform data

>>>> /sdata/code/.

>>>>> instead of trying to convert the driver to device tree.

>>>> Convert the platfrom data, I meant. But I already wrote about that I think.

>>>>> Yes, I knew about this.

>>>> But still attempted to document and use the data-only device tree properties
>>>> (which was pointless in the light of procediral platfrom data)?

>>> Yes, I added this information to next patch.

>> WHich information, I didn't understand?

> sorry, I was not understand your mail by mistake.
> You believe that without OF_DEV_AUXDATA, that it should be fully migrated to
> the DT from platformdata. right?

    No, the contrary. OF_DEV_AUXDATA should be used and platfrom data 
therefore *not* be convereted to DT propertiies.

>>>>>>> +
>>>>>>> +#ifdef CONFIG_OF
>>>>>>> +static const struct of_device_id sh_eth_match[] = {
>>>>>>> + { .compatible = "renesas,sh-eth-gigabit", },
>>>>>>> + { .compatible = "renesas,sh-eth-sh4", },
>>>>>>> + { .compatible = "renesas,sh-eth-sh3-sh2", },

>>>>> Therefore, the compatible property of this device becomes <CPU>-sh-eth
>>>>> or <CPU>-sh-eth-<ETHER TYPE>.

>>>>> How about this?

>>>> Sounds better. I think however that the conversion of this driver to device
>>>> tree shouldn't be done without getting rid of the current #ifdef mess in it
>>>> (which is still on my agenda). I think that the 'register_type' field should
>>>> move from the platform data to the 'struct sh_eth_cpu_data' in the process.

>>> I see. this problem will fix next step, I think.

>> No, not at all. If we don't get rid of the #ifdef mess, adding device tree
>> support will have to add even more of it.

> But sh-eth was used by SH and sh-mobile.

    So what?

> I think we can migrate to DT.

    I don't think we should do it before removing the #ifdef's.

> However, I think it is not possible to remove idfef completely immediately.

    Immediately or not quite so, it was the task I was given.

>>> Best regards,
>>> Nobuhiro

WBR, Sergei
