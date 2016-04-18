From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: switchdev fib offload issues
Date: Mon, 18 Apr 2016 10:59:37 -0600
Message-ID: <57151279.4020806@cumulusnetworks.com>
References: <20160418154757.GA2059@nanopsycho.amit.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	jhs@mojatatu.com, john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com, f.fainelli@gmail.com, andrew@lunn.ch,
	vivien.didelot@savoirfairelinux.com, tgraf@suug.ch,
	aduyck@mirantis.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f175.google.com ([209.85.223.175]:35781 "EHLO
	mail-io0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752535AbcDRQ7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2016 12:59:41 -0400
Received: by mail-io0-f175.google.com with SMTP id g185so200778308ioa.2
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2016 09:59:41 -0700 (PDT)
In-Reply-To: <20160418154757.GA2059@nanopsycho.amit.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/16 9:47 AM, Jiri Pirko wrote:
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

Yes, we have a local patch where I do create the table for IPv6. Can do 
that for IPv4 as well. Some other clean ups are needed in this area - 
like the ability to delete a table

>
> 3) per-VFR/master_netdev
> 	In this case, the policy would be also set during
> 	the creation of VFR master. From user perspective,
> 	this looks same as 2)
> 	The policy value would be stored in struct net_vrf (vrf private).

The VRF device is really only used for guiding lookups, not inserting 
routes.

A per table/VRF policy (option 2) seems more appropriate.
