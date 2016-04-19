From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: switchdev fib offload issues
Date: Tue, 19 Apr 2016 09:02:03 +0200
Message-ID: <20160419070203.GB1958@nanopsycho.orion>
References: <20160418154757.GA2059@nanopsycho.amit.cz>
 <57151279.4020806@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com, f.fainelli@gmail.com, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, tgraf@suug.ch,
	aduyck@mirantis.com
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:37686 "EHLO
	mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752060AbcDSHCG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Apr 2016 03:02:06 -0400
Received: by mail-wm0-f53.google.com with SMTP id n3so12793587wmn.0
        for <netdev@vger.kernel.org>; Tue, 19 Apr 2016 00:02:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57151279.4020806@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Apr 18, 2016 at 06:59:37PM CEST, dsa@cumulusnetworks.com wrote:
>On 4/18/16 9:47 AM, Jiri Pirko wrote:
>>Proposed solutions (ideas):
>>1) per-netns. Add a procfs file:
>>	/proc/sys/net/ipv4/route/fib_offload_error_policy
>>	  with values: "evict" - default, current behaviour
>>                        "fail" - propagate offload error to user
>>	The policy value would be stored in struct net.
>>
>>2) per-VRF/table
>>	When user creates a VRF master, he specifies a table ID
>>	this VRF is going to use. I propose to extend this so
>>	he can pass a policy ("evict"/"fail").
>>	The policy value would be stored in struct fib_table or
>>	struct fib6_table. The problem is that vfr only saves
>>	table ID, allocates dst but does not actually create
>>	table. That might be created later. But I think this
>>	could be resolved.
>
>Yes, we have a local patch where I do create the table for IPv6. Can do that
>for IPv4 as well. Some other clean ups are needed in this area - like the
>ability to delete a table
>
>>
>>3) per-VFR/master_netdev
>>	In this case, the policy would be also set during
>>	the creation of VFR master. From user perspective,
>>	this looks same as 2)
>>	The policy value would be stored in struct net_vrf (vrf private).
>
>The VRF device is really only used for guiding lookups, not inserting routes.
>
>A per table/VRF policy (option 2) seems more appropriate.

Right. Option 2 also seems better to me. Thanks.
