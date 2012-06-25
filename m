From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [RFC net-next (v2) 14/14] ixgbevf: set maximal number of default
 RSS queues
Date: Mon, 25 Jun 2012 09:33:17 -0700
Message-ID: <4FE892CD.1020804@intel.com>
References: <1340624745-8650-1-git-send-email-yuvalmin@broadcom.com> <1340624745-8650-15-git-send-email-yuvalmin@broadcom.com> <4FE88794.9090704@intel.com> <1340639591.2486.25.camel@lb-tlvb-eilong.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Yuval Mintz <yuvalmin@broadcom.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>
To: eilong@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:40701 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754404Ab2FYQdY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jun 2012 12:33:24 -0400
In-Reply-To: <1340639591.2486.25.camel@lb-tlvb-eilong.il.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/25/2012 08:53 AM, Eilon Greenstein wrote:
> On Mon, 2012-06-25 at 08:45 -0700, Alexander Duyck wrote:
>> On 06/25/2012 04:45 AM, Yuval Mintz wrote:
>>> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
>>> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>>>
>>> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
>>> Cc: Alexander Duyck <alexander.h.duyck@intel.com>
>>> Cc: Greg Rose <gregory.v.rose@intel.com>
>>> ---
>>>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c |    2 +-
>>>  1 files changed, 1 insertions(+), 1 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> index f69ec42..7889644 100644
>>> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
>>> @@ -2023,7 +2023,7 @@ static int ixgbevf_set_interrupt_capability(struct ixgbevf_adapter *adapter)
>>>  	 * (roughly) twice the number of vectors as there are CPU's.
>>>  	 */
>>>  	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
>>> -		       (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
>>> +		       netif_get_num_default_rss_queues() * 2) + NON_Q_VECTORS;
>>>  
>>>  	/* A failure in MSI-X entry allocation isn't fatal, but it does
>>>  	 * mean we disable MSI-X capabilities of the adapter. */
>> I'm not even sure why you are bothering to alter this driver since it is
>> currently single queue only.
> Alex,
>
> Can you please explain the logic behind these lines in the current
> implementation?
> 	v_budget = min(adapter->num_rx_queues + adapter->num_tx_queues,
> 		       (int)(num_online_cpus() * 2)) + NON_Q_VECTORS;
> It looks as if you were trying to be generic and support a future in
> which this driver will support more than a single queue - to be future
> ready, this RFC is replacing the usage of num_online_cpus with
> netif_get_num_default_rss_queues. Are you suggesting to remove these
> lines all together? Keeping this minimum function with only the
> num_online_cpus does not seem right without considering also the new
> default value.
>
> Thanks,
> Eilon
Eilon,

It seems like you didn't listen to anything I told you for the last
round of patches.

You are confusing interrupt vectors with queues as you did with ixgbe. 
The VF driver supports up to 3 interrupts, but is only single queue.  As
such we can split things out so that we either support one vector with
both Tx and Rx or separate Tx and Rx vectors.  How many vectors you have
doesn't really matter anyway since this patch doesn't limit queues.  All
it does is limit the number of interrupt vectors.

I suggest you locate where we set "adapter->num_rx_queues" and attempt
to address the issue there.

Thanks,

Alex
