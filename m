From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] net: sh-eth: Add flag to determine the type of TSU register
Date: Tue, 07 May 2013 11:36:49 +0900
Message-ID: <518868C1.7010502@renesas.com>
References: <1366248372-28791-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <517007B0.7010807@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor2.renesas.com ([210.160.252.172]:38352 "EHLO
	relmlor2.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758499Ab3EGChI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 22:37:08 -0400
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor2.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00BD1PXFG750@relmlor2.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:36:51 +0900 (JST)
Received: from relmlac2.idc.renesas.com ([10.200.69.22])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0MME00EQKPXF5BE0@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:36:51 +0900 (JST)
In-reply-to: <517007B0.7010807@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013/04/18 23:48), Sergei Shtylyov wrote:
> Hello.
>
> On 18-04-2013 5:26, Nobuhiro Iwamatsu wrote:
>
>> Some sh-eth devices may have two ether devices in the inside.
>
> s/in the//

I will remove this.

>
>> And the function of TSU is accessed from each ether device.
>> In this case, sh-eth need to remap address using devm_ioremap(),
>> without using devm_ioremap_resource().
>
> Do you mean TSU region is shared between Ether devices?
>
>> acl_multi_reg
>
> You meant 'tsu_multi_reg'.
>
>> of sh_eth_cpu_data is used for this control.
>
> So, "multi" here means "shared"?
>

Yes, your comment is right.
I will change variable name from tsu_multi_reg to tsu_shared_reg.

>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> [...]
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index a7499cb..d9458ae 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
>> @@ -2743,7 +2747,12 @@ static int sh_eth_drv_probe(struct platform_device *pdev)
>> ret = -ENODEV;
>> goto out_release;
>> }
>> - mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
>> +
>> + if (mdp->cd->tsu_multi_reg)
>> + mdp->tsu_addr = devm_ioremap(&pdev->dev, rtsu->start,
>> + resource_size(rtsu));
>> + else
>> + mdp->tsu_addr = devm_ioremap_resource(&pdev->dev, rtsu);
>> if (IS_ERR(mdp->tsu_addr)) {
>> ret = PTR_ERR(mdp->tsu_addr);
>> goto out_release;
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
>> index 1ddc9f2..6f9a997 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.h
>> +++ b/drivers/net/ethernet/renesas/sh_eth.h
>> @@ -472,6 +472,7 @@ struct sh_eth_cpu_data {
>> unsigned tpauser:1; /* EtherC have TPAUSER */
>> unsigned bculr:1; /* EtherC have BCULR */
>> unsigned tsu:1; /* EtherC have TSU */
>> + unsigned tsu_multi_reg:1; /* EtherC have TSU multi register */
>
> Please indent the comment with tab(s) like all the others.

OK, I will fix.

Nobuhiro
