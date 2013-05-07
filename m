From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH v2 6/8] net: sh-eth: Add irq configureation flags in
 sh_eth_cpu_data
Date: Tue, 07 May 2013 11:57:12 +0900
Message-ID: <51886D88.3000307@renesas.com>
References: <1366279869-23387-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <1366279869-23387-6-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <517009D7.7080700@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshihiro.shimoda.uh@renesas.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:44058 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758800Ab3EGC5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 22:57:19 -0400
Received: from relmlir2.idc.renesas.com ([10.200.68.152])
 by relmlor3.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME007CBQVHVZ60@relmlor3.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:57:17 +0900 (JST)
Received: from relmlac3.idc.renesas.com ([10.200.69.23])
 by relmlir2.idc.renesas.com ( SJSMS)
 with ESMTP id <0MME00EY8QVHDEF0@relmlir2.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 07 May 2013 11:57:17 +0900 (JST)
In-reply-to: <517009D7.7080700@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

(2013/04/18 23:57), Sergei Shtylyov wrote:
> Hello.
>
> On 18-04-2013 14:11, Nobuhiro Iwamatsu wrote:
>
>> sh-eth is supporting some SH and shmobile CPU. CPU with two or more networked
>> devices is in these, these specify IRQF_SHARED as IRQ configureation flags.
>> This changes to set IRQ configureation flags using in sh_eth_cpu_data.
>
>> Signed-off-by: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
> [...]
>
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
>> index af8c225..a4e337f 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.c
>> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
>> @@ -1920,14 +1923,7 @@ static int sh_eth_open(struct net_device *ndev)
>> pm_runtime_get_sync(&mdp->pdev->dev);
>>
>> ret = request_irq(ndev->irq, sh_eth_interrupt,
>> -#if defined(CONFIG_CPU_SUBTYPE_SH7763) || \
>> - defined(CONFIG_CPU_SUBTYPE_SH7764) || \
>> - defined(CONFIG_CPU_SUBTYPE_SH7757)
>> - IRQF_SHARED,
>> -#else
>> - 0,
>> -#endif
>
> Isn't it simpler to always pass IRQF_SHARED?
>

I think there is a mechanism to separate the setting par CPU,
split is good.

>> - ndev->name, ndev);
>> + mdp->cd->irq_flags, ndev->name, ndev);
>> if (ret) {
>> dev_err(&ndev->dev, "Can not assign IRQ number\n");
>> return ret;
>> diff --git a/drivers/net/ethernet/renesas/sh_eth.h b/drivers/net/ethernet/renesas/sh_eth.h
>> index f86ea96..0772ec1 100644
>> --- a/drivers/net/ethernet/renesas/sh_eth.h
>> +++ b/drivers/net/ethernet/renesas/sh_eth.h
>> @@ -463,6 +463,7 @@ struct sh_eth_cpu_data {
>> unsigned long tx_error_check;
>>
>> /* hardware features */
>> + unsigned long irq_flags; /* IRQ configuration flags */
>
> Comment should have been indented with tabs like the others.
>

OK, I will fix.

>> unsigned no_psr:1; /* EtherC DO NOT have PSR */
>> unsigned apr:1; /* EtherC have APR */
>> unsigned mpr:1; /* EtherC have MPR */
>> @@ -508,6 +509,7 @@ struct sh_eth_private {
>> int duplex;
>> int port; /* for TSU */
>> int vlan_num_ids; /* for VLAN tag filter */
>> + unsigned long irq_flags; /* IRQ configuration flags */
>
> You don't seem to use this...

Oh, I will remove. thank you.

Best regards,
   Nobuhiro
