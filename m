From: Daniel Mack <zonque@gmail.com>
Subject: Re: [PATCH 2/4] net: ethernet: cpsw: add optional third memory region
 for CONTROL module
Date: Thu, 22 Aug 2013 20:37:20 +0200
Message-ID: <52165A60.5030602@gmail.com>
References: <1377171448-27924-1-git-send-email-zonque@gmail.com> <1377171448-27924-3-git-send-email-zonque@gmail.com> <5216549E.1010305@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, ujhelyi.m@gmail.com,
	mugunthanvnm@ti.com, vaibhav.bedia@ti.com, d-gerlach@ti.com,
	linux-arm-kernel@lists.infradead.org, linux-omap@vger.kernel.org,
	devicetree@vger.kernel.org
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <5216549E.1010305@cogentembedded.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

On 22.08.2013 20:12, Sergei Shtylyov wrote:
>> @@ -2012,6 +2013,27 @@ static int cpsw_probe(struct platform_device *pdev)
>>   		goto clean_runtime_disable_ret;
>>   	}
>>
>> +	/* If the control memory region is unspecified, continue without it.
>> +	 * If it is specified, but we're unable to reserve it, bail. */
> 
>     According to Documentation/CodingStyle, the networking code's preferred 
> style of multi-line comments is this:
> 
> /* Bla
>   * bla
>   */

Ok, thanks. Will fix.

>> +		goto clean_runtime_disable_ret;
>> +	}
>> +	priv->gmii_sel_reg = devm_ioremap(&pdev->dev, res->start,
>> +					  resource_size(res));
>> +	if (!priv->gmii_sel_reg) {
>> +		dev_err(priv->dev, "unable to map control i/o region\n");
>> +		goto clean_runtime_disable_ret;
>> +	}
> 
>     Why not use devm_ioremap_resource() instead of the above sequence?

Right, that's much nicer. I'll also do that for the devm rework patch.


Thank you for your review!


Daniel

