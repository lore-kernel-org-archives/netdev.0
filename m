From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCHi v2] net: sh_eth: Add support of device tree probe
Date: Tue, 05 Mar 2013 06:37:12 +0900
Message-ID: <51351408.8060806@renesas.com>
References: <1360803091-26400-1-git-send-email-nobuhiro.iwamatsu.yj@renesas.com>
 <87mwv7ofgj.wl%kuninori.morimoto.gx@renesas.com>
 <511C5279.3070008@renesas.com> <20130304080509.EDF323E206B@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Kuninori Morimoto <kuninori.morimoto.gx@renesas.com>,
	netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	magnus.damm@gmail.com, kda@linux-powerpc.org,
	horms+renesas@verge.net.au
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:33989 "EHLO
	relmlor3.renesas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932516Ab3CDVhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Mar 2013 16:37:14 -0500
Received: from relmlir1.idc.renesas.com ([10.200.68.151])
 by relmlor3.idc.renesas.com ( SJSMS)
 with ESMTP id <0MJ500D6TO20ZJ20@relmlor3.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 05 Mar 2013 06:37:12 +0900 (JST)
Received: from relmlac2.idc.renesas.com ([10.200.69.22])
 by relmlir1.idc.renesas.com (SJSMS)
 with ESMTP id <0MJ500485O20SRF0@relmlir1.idc.renesas.com> for
 netdev@vger.kernel.org; Tue, 05 Mar 2013 06:37:12 +0900 (JST)
In-reply-to: <20130304080509.EDF323E206B@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(2013/03/04 17:05), Grant Likely wrote:
> On Thu, 14 Feb 2013 11:56:57 +0900, Nobuhiro Iwamatsu<nobuhiro.iwamatsu.yj@renesas.com>  wrote:
>> (2013/02/14 10:24), Kuninori Morimoto wrote:
>>>> +#ifdef CONFIG_OF
>>>> +	if (np&&   of_device_is_available(np)) {
>>>> +		pd = sh_eth_parse_dt(&pdev->dev, ndev);
>>>> +		if (pdev->dev.platform_data) {
>>>> +			struct sh_eth_plat_data *tmp =
>>>> +				pdev->dev.platform_data;
>>>> +			pd->set_mdio_gate = tmp->set_mdio_gate;
>>>> +			pd->needs_init = tmp->needs_init;
>>>> +		}
>>>> +	} else
>>>> +#endif
>>>
>>> sh_eth_parse_dt() was defined for both CONFIG_OF and !CONFIG_OF.
>>> But it is called only from CONFIG_OF ?
>>>
>>
>> Because of_device_is_available needs CONFIG_OF.
>> I already send a patch which add empty function of of_device_is_available.
>> If this was apply, this ifdef becomes without need.
> 
> Actually, there shouldn't be any reason for a device driver to call
> of_device_is_available() on its own node at all. If the device is not
> available, then a platform_device won't be created. "if (np)" here is
> sufficient.
> 

Yes, you are right.
I re-writed code without of_device_is_available(). I will send new patch soon.

Best regards,
  Nobuhiro
