From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Mon, 18 Jun 2007 23:11:32 +0200
Message-ID: <4676F504.7090901@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC329030D5A10@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:42558 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763174AbXFRVLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jun 2007 17:11:39 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC329030D5A10@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>> Nested netlink attributes, like most qdisc use, instead of 
>> struct tc_rr_qopt (or additionally). The way you've done it 
>> makes it hard to add further attributes later.
>>     
>
> I'm going to need to think about this more, since I'm not immediately
> getting what you're referring to.  I see the qdisc using tc_prio_qopt as
> a single member; do you have an example outside of the qdiscs I can look
> at and see what you're referring to?  Please bear with me: my netlink
> skills are still very green.
>   

Qdisc private parameters are within the TCA_OPTION attribute. The
data under that attribute can either be a structure (which you used)
or more netlink attributes specific to a single qdisc, which allows
to easily add new attributes.

For a simple qdisc example look at sch_red or grep for rta_parse_nested
and nla_parse_nested.

>   
>> BTw, couldn't you just merge sch_rr with prio? AFAICT you 
>> only need a new dequeue function, a new struct Qdisc_ops and 
>> a MODULE_ALIAS.
>>     
>
> Are you suggesting a module that can determine RR or PRIO at runtime?
> Because the two are so similar, I definitely thought about combining
> them, but because of the dequeue difference, you'd need a load-time
> switch to determine which mode to run the module in.  That would break
> ABI for sch_prio, which I was trying to avoid.

Yes, all you need to do is register two different struct Qdisc_ops and
provide an alias for autoloading.


