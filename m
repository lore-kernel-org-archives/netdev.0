From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: switchdev fib offload issues
Date: Mon, 18 Apr 2016 19:17:59 +0200
Message-ID: <571516C7.6070301@stressinduktion.org>
References: <20160418154757.GA2059@nanopsycho.amit.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com, dsa@cumulusnetworks.com, f.fainelli@gmail.com,
	andrew@lunn.ch, vivien.didelot@savoirfairelinux.com, tgraf@suug.ch,
	aduyck@mirantis.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:59964 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752530AbcDRRSM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 13:18:12 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id ABB3720B36
	for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 13:18:06 -0400 (EDT)
In-Reply-To: <20160418154757.GA2059@nanopsycho.amit.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On 18.04.2016 17:47, Jiri Pirko wrote:
> Proposed solutions (ideas):
> 1) per-netns. Add a procfs file:
> 	/proc/sys/net/ipv4/route/fib_offload_error_policy
> 	  with values: "evict" - default, current behaviour
>                         "fail" - propagate offload error to user
> 	The policy value would be stored in struct net.
 >
> 2) per-VRF/table
> 	When user creates a VRF master, he specifies a table ID
> 	this VRF is going to use. I propose to extend this so
> 	he can pass a policy ("evict"/"fail").
> 	The policy value would be stored in struct fib_table or
> 	struct fib6_table. The problem is that vfr only saves
> 	table ID, allocates dst but does not actually create
> 	table. That might be created later. But I think this
> 	could be resolved.
>
> 3) per-VFR/master_netdev
> 	In this case, the policy would be also set during
> 	the creation of VFR master. From user perspective,
> 	this looks same as 2)
> 	The policy value would be stored in struct net_vrf (vrf private).

I agree that a fail policy is probably the way forward regarding the 
issues you outlined.

One question though:

Shouldn't the policy by an attribute of the switch, e.g. configurable by 
devlink (maybe also not the right place)? Not sure how user space can 
otherwise make correct assumptions about the state of the switch and 
initiate proper countermeasures (e.g. reducing the smallest prefix 
length installed to hardware).

Bye,
Hannes
