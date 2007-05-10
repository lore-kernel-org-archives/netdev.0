From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 14:32:47 -0400
Message-ID: <4643654F.5060207@hp.com>
References: <OF305F038C.A48D4C37-ON652572D7.00538ECA-652572D7.00546E39@in.ibm.com>	<46435412.50800@hp.com> <464360D6.4080402@hp.com> <46436274.4060804@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Krishna Kumar2 <krkumar2@in.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:36792 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753569AbXEJSct (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 14:32:49 -0400
In-Reply-To: <46436274.4060804@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rick Jones wrote:
> Vlad Yasevich wrote:
>> Rick Jones wrote:
>>
>>>> It is the reverse - GSO will segment one super-packet just before
>>>> calling
>>>> the driver so that the stack is traversed only once. In my case, I am
>>>> trying to send out multiple skbs, possibly small packets, in one shot.
>>>> GSO will not help for small packets.
>>>
>>> If there are small packets that implies small sends, which suggests that
>>> they would be coalesced either implicitly by the Nagle algorithm or
>>> explicitly with TCP_CORK no?
>>>
>>> rick jones
>>> -
>>
>>
>> May be for TCP?  What about other protocols?
> 
> There are other protocols?-)  True, UDP, and I suppose certain modes of
> SCTP might be sending streams of small packets, as might TCP with
> TCP_NODELAY set.
> 
> Do they often queue-up outside the driver?

Not sure if DCCP might fall into this category as well...

I think the idea of this patch is gather some number of these small packets and
shove them at the driver in one go instead of each small packet at a time.

I might be helpful, but reserve judgment till I see more numbers.

-vlad
