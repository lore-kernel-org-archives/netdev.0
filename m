From: "Amir Vadai\"" <amir@vadai.me>
Subject: Re: [net-next PATCH 0/7] tc offload for cls_u32 on ixgbe
Date: Wed, 3 Feb 2016 12:11:09 +0200
Message-ID: <20160203101109.GB20905@office.Home>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ogerlitz@mellanox.com, jiri@resnulli.us, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35939 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754388AbcBCKIM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Feb 2016 05:08:12 -0500
Received: by mail-wm0-f65.google.com with SMTP id 128so6587826wmz.3
        for <netdev@vger.kernel.org>; Wed, 03 Feb 2016 02:08:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 03, 2016 at 01:27:32AM -0800, John Fastabend wrote:
> This extends the setup_tc framework so it can support more than just
> the mqprio offload and push other classifiers and qdiscs into the
> hardware. The series here targets the u32 classifier and ixgbe
> driver. I worked out the u32 classifier because it is protocol
> oblivious and aligns with multiple hardware devices I have access
> to. I did an initial implementation on ixgbe because (a) I have one
> in my box (b) its a stable driver and (c) it is relatively simple
> compared to the other devices I have here but still has enough
> flexibility to exercise the features of cls_u32.
> 
> I intentionally limited the scope of this series to the basic
> feature set. Specifically this uses a 'big hammer' feature bit
> to do the offload or not. If the bit is set you get offloaded rules
> if it is not then rules will not be offloaded. If we can agree on
> this patch series there are some more patches on my queue we can
> talk about to make the offload decision per rule using flags similar
> to how we do l2 mac updates. Additionally the error strategy can
> be improved to be hard aborting, log and continue, etc. I think
> these are nice to have improvements but shouldn't block this series.
> 
> Also by adding get_parse_graph and set_parse_graph attributes as
> in my previous flow_api work we can build programmable devices
> and programmatically learn when rules can or can not be loaded
> into the hardware. Again future work.
> 
> Any comments/feedback appreciated.
> 
> Thanks,
> John
> 
> ---
> 
> John Fastabend (7):
>       net: rework ndo tc op to consume additional qdisc handle parameter
>       net: rework setup_tc ndo op to consume general tc operand
>       net: sched: add cls_u32 offload hooks for netdevs
>       net: add tc offload feature flag
>       net: tc: helper functions to query action types
>       net: ixgbe: add minimal parser details for ixgbe
>       net: ixgbe: add support for tc_u32 offload
> 

Hi John,

Nice work :)

I will add mlx5 support, and see if can live with u32. If not - will
add flower support too.

Amir
