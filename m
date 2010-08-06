From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/9] net classifier: dont allow filters on semi-classful
 qdisc
Date: Sat, 07 Aug 2010 00:26:17 +0200
Message-ID: <4C5C8C09.9070206@gmail.com>
References: <20100806193548.007978639@vyatta.com>	<20100806193558.580890552@vyatta.com>	<4C5C7D9F.4040303@gmail.com> <20100806145818.66d389eb@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:63676 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751782Ab0HFW0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Aug 2010 18:26:23 -0400
Received: by bwz3 with SMTP id 3so254568bwz.19
        for <netdev@vger.kernel.org>; Fri, 06 Aug 2010 15:26:22 -0700 (PDT)
In-Reply-To: <20100806145818.66d389eb@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger wrote, On 06.08.2010 23:58:

> On Fri, 06 Aug 2010 23:24:47 +0200
> Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
>> Stephen Hemminger wrote, On -10.01.-28163 20:59:
>>
>>> There are several qdisc which only support a single class (sfq, mq, tbf)
>>> and the kernel would dereference a null pointer (bind_tcf), if a user
>>> attempted to apply a filter one of these classes.
>>
>>
>> mq and tbf can't have this issue because they don't have
>> .tcf_chain class method. sfq should support it on purpose
>> after this patch:
>>
>> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=7d2681a6ff4f9ab5e48d02550b4c6338f1638998
>> and needs tiny fix only.
> 
> Probably best to fix both ways.  Fix sfq to allow filters to
> be chained, and fix API to prevent refuse to allow qdisc to
> register with tcf_chain && !bind_tcf
> 

Yes, but your patch needs a different changelog and I'm not sure
it's necessary for stable (there should be no other such cases
for now).

Jarek P.
