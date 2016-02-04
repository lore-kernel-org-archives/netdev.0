From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [net-next PATCH 0/7] tc offload for cls_u32 on ixgbe
Date: Thu, 4 Feb 2016 10:16:56 +0100
Message-ID: <20160204091656.GA2198@nanopsycho.orion>
References: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: amir@vadai.me, ogerlitz@mellanox.com, jhs@mojatatu.com,
	jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org,
	davem@davemloft.net
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:36095 "EHLO
	mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751082AbcBDJQ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Feb 2016 04:16:58 -0500
Received: by mail-wm0-f54.google.com with SMTP id p63so201887871wmp.1
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 01:16:58 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160203092708.1356.13733.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Feb 03, 2016 at 10:27:32AM CET, john.fastabend@gmail.com wrote:
>This extends the setup_tc framework so it can support more than just
>the mqprio offload and push other classifiers and qdiscs into the
>hardware. The series here targets the u32 classifier and ixgbe
>driver. I worked out the u32 classifier because it is protocol
>oblivious and aligns with multiple hardware devices I have access
>to. I did an initial implementation on ixgbe because (a) I have one
>in my box (b) its a stable driver and (c) it is relatively simple
>compared to the other devices I have here but still has enough
>flexibility to exercise the features of cls_u32.
>
>I intentionally limited the scope of this series to the basic
>feature set. Specifically this uses a 'big hammer' feature bit
>to do the offload or not. If the bit is set you get offloaded rules
>if it is not then rules will not be offloaded. If we can agree on
>this patch series there are some more patches on my queue we can
>talk about to make the offload decision per rule using flags similar
>to how we do l2 mac updates. Additionally the error strategy can
>be improved to be hard aborting, log and continue, etc. I think
>these are nice to have improvements but shouldn't block this series.
>
>Also by adding get_parse_graph and set_parse_graph attributes as
>in my previous flow_api work we can build programmable devices
>and programmatically learn when rules can or can not be loaded
>into the hardware. Again future work.
>
>Any comments/feedback appreciated.

I like this being thin and elegant solution. However, ~2 years ago when I
pushed openvswitch kernel datapath offload patchset, people were yelling
at me that it is not generic enough solution, that tc has to be able
to use the api (Jamal :)), nftables as well.

Now this patch is making offload strictly tc-based and nobody seems to
care :) I do. I think that we might try to find some generic middle layer.

Let's discuss this more in person next week.

Thanks!
