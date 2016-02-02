From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [RFC PATCH 0/7] tc cls_u32 hardware interface
Date: Tue, 02 Feb 2016 06:58:22 -0800
Message-ID: <56B0C40E.8070205@gmail.com>
References: <20160201014555.13871.56591.stgit@john-Precision-Tower-5810> <20160202114943.GA2191@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: anjali.singhai@intel.com, jesse.brandeburg@intel.com,
	jhs@mojatatu.com, ast@fb.com, donald.c.skidmore@intel.com,
	horms@verge.net.au, netdev@vger.kernel.org, tgraf@suug.ch,
	davem@davemloft.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33150 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932377AbcBBO6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 09:58:37 -0500
Received: by mail-pa0-f50.google.com with SMTP id cy9so100385630pac.0
        for <netdev@vger.kernel.org>; Tue, 02 Feb 2016 06:58:37 -0800 (PST)
In-Reply-To: <20160202114943.GA2191@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-02 03:49 AM, Jiri Pirko wrote:
> Mon, Feb 01, 2016 at 02:48:32AM CET, john.fastabend@gmail.com wrote:
>> I was waiting for net-next to open to submit this but it seems like
>> a good idea to get an RFC out there for folks to start looking over.
>>
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
>> I am working on similar support for the other Intel devices now
>> as well namely i40e and fm10k.
>>
>> Also in the future work bin by adding get_parse_graph and
>> set_parse_graph attributes as in my previous flow_api work we
>> can build programmable devices and programmatically learn when
>> rules can or can not be loaded into the hardware.
>>
>> Note this series is on a slightly behind net-next stack I think it
>> should apply to the latest but I haven't updated the series for
>> awhile I'll do that soon I was sort of waiting for net-next to
>> open to do this.
>>
>> Any comments/feedback appreciated.
> 
> I like this patchset. I gave it a quick peek and I it looks to me like
> the correct way to go. There are couple of things needed to be decided

Great.

,
> as you described them (e. g. per-rule offload) - we should discuss them
> on netdev conference. I hope you will be there.
> 

I'll be at the conference so we can discuss it there. Although even
without the per-rule flow this set is useful. Like I noted I view that
as an optimization and its much more useful on a NIC where host traffic
is the norm vs a switch where host traffic is most likely the exception.

> I curious about how do you plan to expose the parse graphs get/set ops...

The current stack of patches I have on my dev box use a new netlink
handler. ethtool could work as well but my preference is netlink in
this case.
