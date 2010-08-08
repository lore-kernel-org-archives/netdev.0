From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/9] net classifier: dont allow filters on
 semi-classful qdisc
Date: Sat, 07 Aug 2010 22:59:05 -0700 (PDT)
Message-ID: <20100807.225905.135552260.davem@davemloft.net>
References: <4C5C7D9F.4040303@gmail.com>
	<20100806145818.66d389eb@nehalam>
	<4C5C8C09.9070206@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40839
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751146Ab0HHF6q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Aug 2010 01:58:46 -0400
In-Reply-To: <4C5C8C09.9070206@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Sat, 07 Aug 2010 00:26:17 +0200

> Stephen Hemminger wrote, On 06.08.2010 23:58:
> 
>> On Fri, 06 Aug 2010 23:24:47 +0200
>> Jarek Poplawski <jarkao2@gmail.com> wrote:
>> 
>>> Stephen Hemminger wrote, On -10.01.-28163 20:59:
>>>
>>>> There are several qdisc which only support a single class (sfq, mq, tbf)
>>>> and the kernel would dereference a null pointer (bind_tcf), if a user
>>>> attempted to apply a filter one of these classes.
>>>
>>>
>>> mq and tbf can't have this issue because they don't have
>>> .tcf_chain class method. sfq should support it on purpose
>>> after this patch:
>>>
>>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7d2681a6ff4f9ab5e48d02550b4c6338f1638998
>>> and needs tiny fix only.
>> 
>> Probably best to fix both ways.  Fix sfq to allow filters to
>> be chained, and fix API to prevent refuse to allow qdisc to
>> register with tcf_chain && !bind_tcf
>> 
> 
> Yes, but your patch needs a different changelog and I'm not sure
> it's necessary for stable (there should be no other such cases
> for now).

Right.

I'm tossing this series since there are dependencies upon this first
patch for which we've arrived at a different solution (Jarek's
patch).
