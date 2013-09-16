From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 0/4] bridge: Fix problems around the PVID
Date: Mon, 16 Sep 2013 13:49:26 -0400
Message-ID: <523744A6.5090001@redhat.com>
References: <1378808874.3988.2.camel@ubuntu-vm-makita>  <20130912.160033.779509034953932316.davem@davemloft.net> <1379074013.1678.16.camel@localhost.localdomain>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, makita.toshiaki@lab.ntt.co.jp,
	netdev@vger.kernel.org,
	Fernando Luis Vazquez Cao <fernando_b1@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>
To: Toshiaki Makita <toshiaki.makita1@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48557 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751148Ab3IPRtv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 13:49:51 -0400
In-Reply-To: <1379074013.1678.16.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/13/2013 08:06 AM, Toshiaki Makita wrote:
> On Thu, 2013-09-12 at 16:00 -0400, David Miller wrote:
>> From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>> Date: Tue, 10 Sep 2013 19:27:54 +0900
>>
>>> There seem to be some undesirable behaviors related with PVID.
>>> 1. It has no effect assigning PVID to a port. PVID cannot be applied
>>> to any frame regardless of whether we set it or not.
>>> 2. FDB entries learned via frames applied PVID are registered with
>>> VID 0 rather than VID value of PVID.
>>> 3. We can set 0 or 4095 as a PVID that are not allowed in IEEE 802.1Q.
>>> This leads interoperational problems such as sending frames with VID
>>> 4095, which is not allowed in IEEE 802.1Q, and treating frames with VID
>>> 0 as they belong to VLAN 0, which is expected to be handled as they have
>>> no VID according to IEEE 802.1Q.
>>>
>>> Note: 2nd and 3rd problems are potential and not exposed unless 1st problem
>>> is fixed, because we cannot activate PVID due to it.
>>
>> Please work out the issues in patch #2 with Vlad and resubmit this
>> series.
>>
>> Thank you.
>
> I'm hovering between whether we should fix the issue by changing vlan 0
> interface behavior in 8021q module or enabling a bridge port to sending
> priority-tagged frames, or another better way.
>
> If you could comment it, I'd appreciate it :)
>
>
> BTW, I think what is discussed in patch #2 is another problem about
> handling priority-tags, and it exists without this patch set applied.
> It looks like that we should prepare another patch set than this to fix
> that problem.
>
> Should I include patches that fix the priority-tags problem in this
> patch set and resubmit them all together?
>

I am thinking that we might need to do it in bridge and it looks like
the simplest way to do it is to have default priority regeneration table
(table 6-5 from 802.1Q doc).

That way I think we would conform to the spec.

-vlad

>
> Thanks,
>
> Toshiaki Makita
>
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
