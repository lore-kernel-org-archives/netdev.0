From: Cong Wang <amwang@redhat.com>
Subject: Re: [v4 Patch 1/2] s2io: add dynamic LRO disable support
Date: Fri, 25 Jun 2010 16:59:58 +0800
Message-ID: <4C24700E.5010301@redhat.com>
References: <20100622085415.5566.22523.sendpatchset@localhost.localdomain> <1277207080.2091.2.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sgruszka@redhat.com,
	herbert.xu@redhat.com, Ramkrishna.Vepa@exar.com,
	davem@davemloft.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54966 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752006Ab0FYIz4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 04:55:56 -0400
In-Reply-To: <1277207080.2091.2.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/22/10 19:44, Ben Hutchings wrote:
> On Tue, 2010-06-22 at 04:50 -0400, Amerigo Wang wrote:
>> This patch adds dynamic LRO diable support for s2io net driver.
>>
>> (I don't have s2io card, so only did compiling test. Anyone who wants
>> to test this is more than welcome.)
>>
>> This is based on Neil's initial work, and heavily modified
>> based on Ramkrishna's suggestions.
> [...]
>> +static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
>> +{
>> +	struct s2io_nic *sp = netdev_priv(dev);
>> +	int rc = 0;
>> +	int changed = 0;
>> +
>> +	if (data&  ~ETH_FLAG_LRO)
>> +		return -EOPNOTSUPP;
>> +
>> +	if (data&  ETH_FLAG_LRO) {
>> +		if (lro_enable) {
>> +			if (!(dev->features&  NETIF_F_LRO)) {
>> +				dev->features |= NETIF_F_LRO;
>> +				changed = 1;
>> +			}
>> +		} else
>> +			rc = -EOPNOTSUPP;
>
> Should lro_enable=0 really prevent enabling it later?  This seems
> unusual.
>

I agree with Stanislaw on this point.


>> +	} else if (dev->features&  NETIF_F_LRO) {
>> +		dev->features&= ~NETIF_F_LRO;
>> +		changed = 1;
>> +	}
>> +
>> +	if (changed&&  netif_running(dev)) {
>> +		s2io_stop_all_tx_queue(sp);
>> +		s2io_card_down(sp);
>> +		sp->lro = dev->features&  NETIF_F_LRO;
> [...]
>
> This means s2io_nic::lro and ring_info::lro can have the value
> NETIF_F_LRO, where previously they would only have the value 0 or 1.  I
> don't know whether this could be a problem, but the safe thing to do is
> to coerce the value by writing !!(dev->features&  NETIF_F_LRO).
>

Yeah, agreed.
It seems that Jon already fixed this when he updated the patch.

Thanks!
