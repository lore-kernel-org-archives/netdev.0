From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH 7/7] gianfar: add support for wake-on-packet
Date: Fri, 4 Nov 2011 16:13:46 -0500
Message-ID: <4EB4558A.8070105@freescale.com>
References: <1320410403-14639-1-git-send-email-chenhui.zhao@freescale.com> <4EB45515.6060405@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<afleming@freescale.com>
To: Zhao Chenhui <chenhui.zhao@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe003.messaging.microsoft.com ([216.32.181.183]:56636
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751016Ab1KDVNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Nov 2011 17:13:50 -0400
In-Reply-To: <4EB45515.6060405@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/04/2011 04:11 PM, Scott Wood wrote:
> On 11/04/2011 07:40 AM, Zhao Chenhui wrote:
>>  static int gfar_suspend(struct device *dev)
>>  {
>> @@ -1268,9 +1443,17 @@ static int gfar_suspend(struct device *dev)
>>  	struct gfar __iomem *regs = priv->gfargrp[0].regs;
>>  	unsigned long flags;
>>  	u32 tempval;
>> -
>>  	int magic_packet = priv->wol_en &&
>> -		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
>> +		(priv->wol_opts & GIANFAR_WOL_MAGIC);
>> +	int arp_packet = priv->wol_en &&
>> +		(priv->wol_opts & GIANFAR_WOL_ARP);
>> +
>> +	if (arp_packet) {
>> +		pmc_enable_wake(priv->ofdev, PM_SUSPEND_MEM, 1);
>> +		pmc_enable_lossless(1);
>> +		gfar_arp_suspend(ndev);
>> +		return 0;
>> +	}
> 
> How do we know this isn't standby?

Or suspend to disk, for that matter?

-Scott
