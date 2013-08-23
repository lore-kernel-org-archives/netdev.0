From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH v5 2/5] net: ethernet: cpsw: add optional third memory
 region for CONTROL module
Date: Fri, 23 Aug 2013 21:14:32 +0200
Message-ID: <5217B498.9010706@gmail.com>
References: <1377283987-20040-1-git-send-email-zonque@gmail.com> <1377283987-20040-3-git-send-email-zonque@gmail.com> <5217B3BE.8020003@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bcousson@baylibre.com, nsekhar@ti.com,
	davem@davemloft.net, ujhelyi.m@gmail.com, mugunthanvnm@ti.com,
	vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:43224 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753426Ab3HWTOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 15:14:36 -0400
In-Reply-To: <5217B3BE.8020003@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.08.2013 21:10, Sergei Shtylyov wrote:
> Hello.
> 
> On 08/23/2013 10:53 PM, Daniel Mack wrote:
> 
>> At least the AM33xx SoC has a control module register to configure
>> details such as the hardware ethernet interface mode.
> 
>> I'm not sure whether all SoCs which feature the cpsw block have such a
>> register, so that third memory region is considered optional for now.
> 
>> Signed-off-by: Daniel Mack <zonque@gmail.com>
>> ---
>>   Documentation/devicetree/bindings/net/cpsw.txt | 5 ++++-
>>   drivers/net/ethernet/ti/cpsw.c                 | 5 +++++
>>   2 files changed, 9 insertions(+), 1 deletion(-)
> 
>> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
>> index fc3263f..4feba2f 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
> [...]
>> @@ -1989,6 +1990,10 @@ static int cpsw_probe(struct platform_device *pdev)
>>   		goto clean_runtime_disable_ret;
>>   	}
>>
>> +	/* Don't fail hard if the optional control memory region is missing */
>> +	res = platform_get_resource(pdev, IORESOURCE_MEM, 2);
>> +	priv->gmii_sel_reg = devm_ioremap_resource(&pdev->dev, res);
> 
>     Hm, but why now you don't fail if devm_ioremap_resource() fails?

Well, because I thought maybe we should just ignore failures of that
kind altogether for this optional resource. There will still be a
warning in that case. Did you like the old approach better?


Daniel
