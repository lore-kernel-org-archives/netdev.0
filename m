From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 2/8] i40e: transmit, receive, and napi
Date: Fri, 23 Aug 2013 11:04:15 -0700 (PDT)
Message-ID: <20130823.110415.1251655571740007987.davem@davemloft.net>
References: <1377224142-25160-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1377224142-25160-3-git-send-email-jeffrey.t.kirsher@intel.com>
	<5217589F.6000602@kpanic.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, shannon.nelson@intel.com,
	peter.p.waskiewicz.jr@intel.com, e1000-devel@lists.sourceforge.net
To: sassmann@kpanic.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41352 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756125Ab3HWSEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Aug 2013 14:04:16 -0400
In-Reply-To: <5217589F.6000602@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>
Date: Fri, 23 Aug 2013 14:42:07 +0200

> On 23.08.2013 04:15, Jeff Kirsher wrote:
>> From: Jesse Brandeburg <jesse.brandeburg@intel.com>
>> 
>> This patch contains the transmit, receive, and napi routines, as well
>> as ancillary routines.
>> 
>> This file is code that is (will be) shared between the VF and PF
>> drivers.
> 
> Just some small nitpicks.
> 
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
>> new file mode 100644
>> index 0000000..ceafef0
>> --- /dev/null
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
> 
> [...]
> 
>> +static void i40e_receive_skb(struct i40e_ring *rx_ring,
>> +			     struct sk_buff *skb, u16 vlan_tag)
>> +{
>> +	struct i40e_vsi *vsi = rx_ring->vsi;
>> +	struct i40e_q_vector *q_vector = rx_ring->q_vector;
>> +	u64 flags = vsi->back->flags;
>> +
>> +	if (vlan_tag & VLAN_VID_MASK)
>> +		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tag);
> 
> Suggesting __constant_htons instead of htons here.

We don't suggest that anymore, because it's completely unnecessary
with the way the macros are implemented.
