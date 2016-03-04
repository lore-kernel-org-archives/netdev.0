From: "Samudrala, Sridhar" <sridhar.samudrala@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next] net: ixgbe: Fix cls_u32 offload
 support for ports and fields with masks.
Date: Fri, 04 Mar 2016 14:16:26 -0800
Message-ID: <56DA093A.8010500@intel.com>
References: <1457120869-3489-1-git-send-email-sridhar.samudrala@intel.com> <1457129413.2936.27.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, john.r.fastabend@intel.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:38742 "EHLO mga04.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759107AbcCDWQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Mar 2016 17:16:33 -0500
In-Reply-To: <1457129413.2936.27.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 3/4/2016 2:10 PM, Jeff Kirsher wrote:
> On Fri, 2016-03-04 at 11:47 -0800, Sridhar Samudrala wrote:
>> Fix support for 16 bit source/dest port matches in ixgbe model.
>> u32 uses a single 32-bit key value for both source and destination
>> ports
>> starting at offset 0. So replace the 2 functions with a single
>> function
>> that takes this key value/mask to program both source and dest ports.
>>
>> Remove the incorrect check for mask in ixgbe_configure_clsu32()
>>
>> Tested with the following filters:
>>
>>   #tc qdisc add dev p4p1 ingress
>>   #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
>>          handle 800:0:1 u32 ht 800: \
>>          match ip dst 11.0.0.1/24 match ip src 11.0.0.2/24 action drop
>>
>>   #tc filter del dev p4p1 parent ffff: protocol ip prio 99 \
>>          handle 800:0:1 u32
>>   #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
>>          handle 1: u32 divisor 1
>>   #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
>>          handle 800:0:10 u32 ht 800: link 1: \
>>          offset at 0 mask 0f00 shift 6 plus 0 eat match ip protocol 6
>> ff
>>   #tc filter add dev p4p1 parent ffff: protocol ip prio 99 \
>>          handle 1:0:10 u32 ht 1: \
>>          match tcp src 1024 ffff match tcp dst 80 ffff action drop
>>
>> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
>> ---
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c  |  3 +--
>>   drivers/net/ethernet/intel/ixgbe/ixgbe_model.h | 17 ++++----------
>> ---
>>   2 files changed, 5 insertions(+), 15 deletions(-)
> Is this v2?  If not, why are you re-sending a patch that is already in
> my queue?  If so, where is the changelog so we know what changed in
> this updated v2 of the patch?
No. This is another patch that fixes other issues on top of the previous 
one.

Thanks
Sridhar
