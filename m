From: Li Yang-R58472 <r58472@freescale.com>
Subject: RE: [PATCH 7/7] gianfar: add support for wake-on-packet
Date: Tue, 8 Nov 2011 11:07:54 +0000
Message-ID: <3F607A5180246847A760FD34122A1E052BC98E@039-SN1MPN1-004.039d.mgd.msft.net>
References: <1320410403-14639-1-git-send-email-chenhui.zhao@freescale.com>
 <4EB45515.6060405@freescale.com> <4EB4558A.8070105@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
 "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
 Fleming Andy-AFLEMING <afleming@freescale.com>
To: Wood Scott-B07421 <B07421@freescale.com>, Zhao Chenhui-B35336
 <B35336@freescale.com>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <4EB4558A.8070105@freescale.com>
Content-Language: en-US
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org



>-----Original Message-----
>From: linuxppc-dev-bounces+leoli=freescale.com@lists.ozlabs.org
>[mailto:linuxppc-dev-bounces+leoli=freescale.com@lists.ozlabs.org] On
>Behalf Of Scott Wood
>Sent: Saturday, November 05, 2011 5:14 AM
>To: Zhao Chenhui-B35336
>Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org; Fleming Andy-
>AFLEMING
>Subject: Re: [PATCH 7/7] gianfar: add support for wake-on-packet
>
>On 11/04/2011 04:11 PM, Scott Wood wrote:
>> On 11/04/2011 07:40 AM, Zhao Chenhui wrote:
>>>  static int gfar_suspend(struct device *dev)  { @@ -1268,9 +1443,17
>>> @@ static int gfar_suspend(struct device *dev)
>>>  	struct gfar __iomem *regs = priv->gfargrp[0].regs;
>>>  	unsigned long flags;
>>>  	u32 tempval;
>>> -
>>>  	int magic_packet = priv->wol_en &&
>>> -		(priv->device_flags & FSL_GIANFAR_DEV_HAS_MAGIC_PACKET);
>>> +		(priv->wol_opts & GIANFAR_WOL_MAGIC);
>>> +	int arp_packet = priv->wol_en &&
>>> +		(priv->wol_opts & GIANFAR_WOL_ARP);
>>> +
>>> +	if (arp_packet) {
>>> +		pmc_enable_wake(priv->ofdev, PM_SUSPEND_MEM, 1);
>>> +		pmc_enable_lossless(1);
>>> +		gfar_arp_suspend(ndev);
>>> +		return 0;
>>> +	}
>>
>> How do we know this isn't standby?
>
>Or suspend to disk, for that matter?

There is nothing we can do for hibernation.  The whole system is literally off.

- Leo
