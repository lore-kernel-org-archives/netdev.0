From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: Re: switchdev fib offload issues
Date: Thu, 21 Apr 2016 06:00:38 -0700
Message-ID: <5718CEF6.3080809@cumulusnetworks.com>
References: <20160418154757.GA2059@nanopsycho.amit.cz> <571516C7.6070301@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org,
	davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	nikolay@cumulusnetworks.com, jhs@mojatatu.com,
	john.fastabend@gmail.com, rami.rosen@intel.com,
	gospo@cumulusnetworks.com, stephen@networkplumber.org,
	sfeldma@gmail.com, dsa@cumulusnetworks.com, f.fainelli@gmail.com,
	andrew@lunn.ch, vivien.didelot@savoirfairelinux.com, tgraf@suug.ch,
	aduyck@mirantis.com
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33930 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751591AbcDUNAm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Apr 2016 09:00:42 -0400
Received: by mail-pa0-f50.google.com with SMTP id r5so26343123pag.1
        for <netdev@vger.kernel.org>; Thu, 21 Apr 2016 06:00:41 -0700 (PDT)
In-Reply-To: <571516C7.6070301@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/18/16, 10:17 AM, Hannes Frederic Sowa wrote:
> Hi Jiri,
>
> On 18.04.2016 17:47, Jiri Pirko wrote:
>> Proposed solutions (ideas):
>> 1) per-netns. Add a procfs file:
>>     /proc/sys/net/ipv4/route/fib_offload_error_policy
>>       with values: "evict" - default, current behaviour
>>                         "fail" - propagate offload error to user
>>     The policy value would be stored in struct net.
> >
>> 2) per-VRF/table
>>     When user creates a VRF master, he specifies a table ID
>>     this VRF is going to use. I propose to extend this so
>>     he can pass a policy ("evict"/"fail").
>>     The policy value would be stored in struct fib_table or
>>     struct fib6_table. The problem is that vfr only saves
>>     table ID, allocates dst but does not actually create
>>     table. That might be created later. But I think this
>>     could be resolved.
>>
>> 3) per-VFR/master_netdev
>>     In this case, the policy would be also set during
>>     the creation of VFR master. From user perspective,
>>     this looks same as 2)
>>     The policy value would be stored in struct net_vrf (vrf private).
>
> I agree that a fail policy is probably the way forward regarding the issues you outlined.
>
> One question though:
>
> Shouldn't the policy by an attribute of the switch, e.g. configurable by devlink (maybe also not the right place)? Not sure how user space can otherwise make correct assumptions about the state of the switch and initiate proper countermeasures (e.g. reducing the smallest prefix length installed to hardware).
>
I am with hannes here. If we introduce a policy, I think it should be global or per switchdev instance (possibly via devlink).
This would be a system policy (set via the administrator) and the user or app does not need to know about it.
