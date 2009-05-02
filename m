From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] qos: Limit a filter's priority to a 16 bit value
Date: Fri, 01 May 2009 19:18:54 -0700 (PDT)
Message-ID: <20090501.191854.218400455.davem@davemloft.net>
References: <273D38FBE7C6FE46A1689FCD014A0B8B495C016A@azsmsx505.amr.corp.intel.com>
	<1241229126.7162.5.camel@dogo.mojatatu.com>
	<273D38FBE7C6FE46A1689FCD014A0B8B495C01C0@azsmsx505.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
To: robert.w.love@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43320
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751792AbZEBCTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2009 22:19:00 -0400
In-Reply-To: <273D38FBE7C6FE46A1689FCD014A0B8B495C01C0@azsmsx505.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Love, Robert W" <robert.w.love@intel.com>
Date: Fri, 1 May 2009 19:10:36 -0700

> jamal wrote:
>> On Fri, 2009-05-01 at 16:30 -0700, Love, Robert W wrote:
>> 
>>> I should be more clear by saying that this should only
>>> fail with filter priorities assigned by the kernel.
>>> I think if the user passes down the priority when
>>> creating the filter it should always be 16bits and it's fine.
>>> 
>>> However, when the kernel is assigning priorities, the
>>> first assigned priority for a filter is 0xC0000000,
>>> the second is "the lowest priority - 1" so 0xBFFFFFFF.
>>> 
>>> It will assign this value in tcf_auto_prio() which will
>>> directly assign the 32bit value to to tp->prio with-
>>> 
>>> tp->prio = nprio ? : tcf_auto_prio(*back);
>> 
>> I think the above should read:
>> tp->prio = nprio ? : TC_H_MAJ(tcf_auto_prio(*back));
>> 
> I think you might be right, although, I don't see why
> we use a u32 when we're always storing a u16.

That's irrelevant.

You've essentially found what turned out to be a one-line bug, and
fixed it by changing and rearranging a lot of things.

So could I just get that one-liner fix patch from somebody?

Thanks :-)

Meanwhile, on the issue of how this value is stored, perhaps someone
intended to support "classful" filter priorities, just as we support
classful qdiscs.  Or perhaps someone had the idea to store the
protocol in there as well, who knows :-)
