From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch 1/2] s2io: add dynamic LRO disable support
Date: Mon, 07 Jun 2010 17:01:13 +0800
Message-ID: <4C0CB559.7020503@redhat.com>
References: <20100603034303.5305.55552.sendpatchset@localhost.localdomain> <20100603153811.7b14a1a8@leela> <FCA91A92EE52B041906A0358FC28FCC38EF129DB8F@FRE1EXCH02.hq.exar.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michal Schmidt <mschmidt@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"herbert.xu@redhat.com" <herbert.xu@redhat.com>,
	"nhorman@redhat.com" <nhorman@redhat.com>,
	"sgruszka@redhat.com" <sgruszka@redhat.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Ramkrishna Vepa <Ramkrishna.Vepa@exar.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47542 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756662Ab0FGI5O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jun 2010 04:57:14 -0400
In-Reply-To: <FCA91A92EE52B041906A0358FC28FCC38EF129DB8F@FRE1EXCH02.hq.exar.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/10 16:53, Ramkrishna Vepa wrote:
>> +static int s2io_ethtool_set_flags(struct net_device *dev, u32 data)
>> +{
>> +	struct s2io_nic *sp = netdev_priv(dev);
>> +	int rc = 0;
>> +	int changed = 0;
>> +
>> +	if (data&  ETH_FLAG_LRO) {
>> +		if (lro_enable) {
>> +			if (!(dev->features&  NETIF_F_LRO)) {
>> +				dev->features |= NETIF_F_LRO;
>> +				changed = 1;
>> +			}
>> +		} else
>> +			rc = -EINVAL;
>> +	} else if (dev->features&  NETIF_F_LRO) {
>> +		dev->features&= ~NETIF_F_LRO;
>> +		changed = 1;
>> +	}
>> +
>> +	if (changed&&  netif_running(dev)) {
>> +		s2io_stop_all_tx_queue(sp);
>> +		s2io_card_down(sp);
>> +		sp->lro = dev->features&  NETIF_F_LRO;
>> +		rc = s2io_card_up(sp);
> In s2io_card_up, update ring->lro too as it is used in the fast path -
> 		struct ring_info *ring =&mac_control->rings[i];
>
>   		ring->mtu = dev->mtu;
> +		ring->lro = sp->lro;
>

Yeah, I missed this important part.


>> +		s2io_start_all_tx_queue(sp);
>
> The following line in init_shared_mem() is redundant and can be removed.
> -	ring->lro = lro_enable;
>

Okay.

I will send an updated version soon.

Thanks a lot!
