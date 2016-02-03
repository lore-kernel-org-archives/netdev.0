From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH 0/7] tc offload for cls_u32 on ixgbe
Date: Wed, 03 Feb 2016 02:21:29 -0800
Message-ID: <56B1D4A9.3050801@gmail.com>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810> <20160203101109.GB20905@office.Home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, jiri@resnulli.us, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: "Amir Vadai\"" <amir@vadai.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:36366 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752116AbcBCKVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:21:44 -0500
Received: by mail-pa0-f53.google.com with SMTP id yy13so11334051pab.3
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:21:43 -0800 (PST)
In-Reply-To: <20160203101109.GB20905@office.Home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-03 02:11 AM, Amir Vadai" wrote:
> On Wed, Feb 03, 2016 at 01:27:32AM -0800, John Fastabend wrote:
>> This extends the setup_tc framework so it can support more than just
>> the mqprio offload and push other classifiers and qdiscs into the
>> hardware. The series here targets the u32 classifier and ixgbe
>> driver. I worked out the u32 classifier because it is protocol
>> oblivious and aligns with multiple hardware devices I have access
>> to. I did an initial implementation on ixgbe because (a) I have one
>> in my box (b) its a stable driver and (c) it is relatively simple
>> compared to the other devices I have here but still has enough
>> flexibility to exercise the features of cls_u32.
>>
>> I intentionally limited the scope of this series to the basic
>> feature set. Specifically this uses a 'big hammer' feature bit
>> to do the offload or not. If the bit is set you get offloaded rules
>> if it is not then rules will not be offloaded. If we can agree on
>> this patch series there are some more patches on my queue we can
>> talk about to make the offload decision per rule using flags similar
>> to how we do l2 mac updates. Additionally the error strategy can
>> be improved to be hard aborting, log and continue, etc. I think
>> these are nice to have improvements but shouldn't block this series.
>>
>> Also by adding get_parse_graph and set_parse_graph attributes as
>> in my previous flow_api work we can build programmable devices
>> and programmatically learn when rules can or can not be loaded
>> into the hardware. Again future work.
>>
>> Any comments/feedback appreciated.
>>
>> Thanks,
>> John
>>
>> ---
>>
>> John Fastabend (7):
>>       net: rework ndo tc op to consume additional qdisc handle parameter
>>       net: rework setup_tc ndo op to consume general tc operand
>>       net: sched: add cls_u32 offload hooks for netdevs
>>       net: add tc offload feature flag
>>       net: tc: helper functions to query action types
>>       net: ixgbe: add minimal parser details for ixgbe
>>       net: ixgbe: add support for tc_u32 offload
>>
> 
> Hi John,
> 
> Nice work :)

Thanks, we will need at least a v2 to fixup some build errors
with various compile flags caught by build_bot and missed by me.

> 
> I will add mlx5 support, and see if can live with u32. If not - will
> add flower support too.

That would be great.

Thanks
.John

> 
> Amir
> 
