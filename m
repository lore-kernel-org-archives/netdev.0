From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 3/3] NET: [SCHED] Qdisc changes and sch_rr added for multiqueue
Date: Fri, 22 Jun 2007 02:26:24 +0200
Message-ID: <467B1730.4090701@trash.net>
References: <D5C1322C3E673F459512FB59E0DDC3290314719B@orsmsx414.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>, hadi@cyberus.ca
To: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:50246 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751164AbXFVA0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jun 2007 20:26:51 -0400
In-Reply-To: <D5C1322C3E673F459512FB59E0DDC3290314719B@orsmsx414.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Waskiewicz Jr, Peter P wrote:
>> The dependencies seem to be very confused. SCHED_PRIO does 
>> not depend on anything new, SCH_RR also doesn't depend on 
>> anything. SCH_PRIO_MQ and SCH_RR_MQ (which is missing) depend 
>> on SCH_PRIO/SCH_RR. A single NET_SCH_MULTIQUEUE option seems 
>> better than adding one per scheduler though.
>>     
>
> I agree with a NET_SCH_MULTIQUEUE option.  However, SCH_RR does depend
> on SCH_PRIO being built since it's the same code, doesn't it?  Maybe I'm
> not understanding something about the build process.  I'll clean this
> up.

The easiest solution is to select SCH_PRIO from SCH_RR.
I head something else in mind initially but that is
needlessly complicated.


>>
>> For the tenth time now, the user should enable this at 
>> runtime. You can't just break things dependant on config options.
>>     
>
> I had this in sch_prio and tc before, and was told to remove it because
> of ABI issues.  I can put it back in, but I'm not sure what those
> previous ABI issues were.  Was it backwards compatibility that you
> referred to before that was broken?

Your tc changes changed the structure in a way that old tc binaries
wouldn't work anymore. This version breaks configurations that use
a number of bands not matching the HW queues when the user enables
the multiqueue compile time option.

Unfortunately prio does not use nested attributes, so the easiest
way is extending struct tc_prio_qopt at the end and checking the
attribute size to decide whether its an old or a new version.

A better fix would be to introduce a new qdisc configuration
attribute that takes precedence before TCA_OPTIONS and have
userspace send both the old non-nested structure and a new
nested configuration. That would make sure we never run into
this problem again.


