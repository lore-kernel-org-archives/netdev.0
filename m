From: Cong Wang <amwang@redhat.com>
Subject: Re: [v2 Patch 2/2] mlx4: add dynamic LRO disable support
Date: Thu, 17 Jun 2010 18:48:35 +0800
Message-ID: <4C19FD83.8050507@redhat.com>
References: <20100609100928.6573.14199.sendpatchset@localhost.localdomain>	<20100609100938.6573.73536.sendpatchset@localhost.localdomain>	<20100609110556.GC2599@dhcp-lab-161.englab.brq.redhat.com>	<4C173B57.70601@redhat.com> <20100615121414.26056d15@dhcp-lab-109.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nhorman@redhat.com, herbert.xu@redhat.com,
	bhutchings@solarflare.com, Ramkrishna.Vepa@exar.com
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30653 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759573Ab0FQKog (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jun 2010 06:44:36 -0400
In-Reply-To: <20100615121414.26056d15@dhcp-lab-109.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/15/10 18:14, Stanislaw Gruszka wrote:
> On Tue, 15 Jun 2010 16:35:35 +0800
> Cong Wang<amwang@redhat.com>  wrote:
>>> BTW: seems default ethtool_op_set_flags introduce a bug on many
>>> devices regarding ETH_FLAG_RXHASH. I think default should
>>> be EOPNOTSUPP, and these few devices that actually support RXHASH
>>> should have custom ethtool_ops->set_flags
>>
>> Hmm, you mean this?
>>
>>    if (data&  ETH_FLAG_RXHASH)
>> +    if (!ops->set_flags)
>> +        return -EOPNOTSUPP;
>> ....
>
> Not really, but I do not have good idea how patch with fix should
> looks.
>
> I dislike fact that we setup ->feature that are not in real supported by
> particular device instead of returning EOPNOTSUPP. This actually include
> both flags NETIF_F_LRO and NETIF_F_RXHASH.
>
> Perhaps ethtool_op_set_flags should be removed and drivers should use
> only custom version. In particular seems e1000e and sfc use this
> function improperly and should have NULL as .set_flags.


This depends on if what ethtool_op_set_flags() does is common for
net drivers.

>
> I will think more about that and maybe cook some patches.
>

Yes, please. Cc me when you post patches.

Thanks.
