From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 14:17:50 +0100
Message-ID: <20150226131750.GE1973@nanopsycho.lan>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226125143.GB23050@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, jpettit@nicira.com, joestringer@nicira.com,
	john.r.fastabend@intel.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, simon.horman@netronome.com,
	shrijeet@gmail.com, gospo@cumulusnetworks.com, bcrl@kvack.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f176.google.com ([74.125.82.176]:37382 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751216AbbBZNRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 08:17:54 -0500
Received: by wesw55 with SMTP id w55so10601386wes.4
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 05:17:53 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20150226125143.GB23050@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 26, 2015 at 01:51:43PM CET, tgraf@suug.ch wrote:
>On 02/26/15 at 08:42am, Jiri Pirko wrote:
>> Hello everyone.
>> 
>> I would like to discuss big next step for switch offloading. Probably
>> the most complicated one we have so far. That is to be able to offload flows.
>> Leaving nftables aside for a moment, I see 2 big usecases:
>> - TC filters and actions offload.
>> - OVS key match and actions offload.
>> 
>> I think it might sense to ignore OVS for now. The reason is ongoing efford
>> to replace OVS kernel datapath with TC subsystem. After that, OVS offload
>> will not longer be needed and we'll get it for free with TC offload
>> implementation. So we can focus on TC now.
>>
>> Here is my list of actions to achieve some results in near future:
>> 1) finish cls_openflow classifier and iproute part of it
>
>I still think that you should consider renaming this or merging
>it with cls_flow. I don't see any relation to OpenFlow in what
>you proposed in the last RFC.

cls_flow does something different. I believe that it is not a good idea
to merge it with cls_openflow.

Relation to OpenFlow is that the cls follows the specification in what
fields of pks should be used for matching.

But I get your point. cls_openflow is the working name. I have no
problem in changing it so something different.


>
>> 2) extend switchdev API for TC cls and acts offloading (using John's flow api?)
>> 3) use rocker to provide offload for cls_openflow and couple of selected actions
>> 4) improve cls_openflow performance (hashtables etc)
>> 5) improve TC subsystem performance in both slow and fast path
>>     -RTNL mutex and qdisc lock removal/reduction, lockless stats update.
>> 6) implement "named sockets" (working name) and implement TC support for that
>>     -ingress qdisc attach, act_mirred target
>> 7) allow tunnels (VXLAN, Geneve, GRE) to be created as named sockets
>> 8) implement TC act_mpls
>> 9) suggest to switch OVS userspace from OVS genl to TC API
>
>I think everybody agrees to unifying code paths and getting rid
>of parallism assuming that it does not introduce a performance
>regression for flow setup rate, throughput, and scale.

Great. I sure plan to focus on performance (on both fast and slow path).

>
>I would also include Linux bridge in this effort as it's also
>based on programmable flows and would thus also benefit from
>the implemented offload functionality.

Well I would leave the bridge alone for now. We are able to offload fdbs
there now easily. But I'm open to the discussion for the future.

Thanks!

Jiri
