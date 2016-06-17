From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next v4 0/4] return offloaded stats as default and
 expose original sw stats
Date: Fri, 17 Jun 2016 16:57:54 +0200
Message-ID: <20160617145754.GC1981@nanopsycho.orion>
References: <1466066237-7719-1-git-send-email-jiri@resnulli.us>
 <20160616.172632.1759391103978744570.davem@davemloft.net>
 <20160617082411.GA1981@nanopsycho.orion>
 <f720df39-75c4-9be1-245d-df63bd40d610@cumulusnetworks.com>
 <20160617140512.GB1981@nanopsycho.orion>
 <57640F2A.7090003@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	nogahf@mellanox.com, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	linville@tuxdriver.com, tgraf@suug.ch, gospo@cumulusnetworks.com,
	sfeldma@gmail.com, sd@queasysnail.net, eranbe@mellanox.com,
	ast@plumgrid.com, edumazet@google.com, hannes@stressinduktion.org,
	f.fainelli@gmail.com
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32936 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751386AbcFQO55 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jun 2016 10:57:57 -0400
Received: by mail-wm0-f66.google.com with SMTP id r201so409937wme.0
        for <netdev@vger.kernel.org>; Fri, 17 Jun 2016 07:57:57 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <57640F2A.7090003@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Jun 17, 2016 at 04:54:34PM CEST, jhs@mojatatu.com wrote:
>On 16-06-17 10:05 AM, Jiri Pirko wrote:
>>Fri, Jun 17, 2016 at 03:48:35PM CEST, dsa@cumulusnetworks.com wrote:
>>>On 6/17/16 2:24 AM, Jiri Pirko wrote:
>>>>
>
>>
>>That is problematic. Existing apps depend on rtnetlink stats. But if we
>>don't count offloaded forwarded packets, the apps don't see anything.
>>Therefore I believe that this patchset approach is better. The existing
>>apps continue to work and future apps can use newly introduces sw_stats
>>to query slowpath traffic. Makes sense to me.
>>
>
>I agree with Jiri. It is a bad idea to depend on ethtool for any of
>this stuff. Is there a way we can tag netlink stats instead
>to indicate they are hardware or software?

In this patchset, those are 2 nl attrs. And they come kernel->user at once.
So I see no need for any tagging. Also won't be appropriate.

>We already have a use case with the tc where someone could get/set
>hardware and/or software.

That is user->kernel.

>
>cheers,
>jamal
