From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next 2/2] geneve: break dependency to network drivers
Date: Wed, 6 Jan 2016 22:18:19 +0100
Message-ID: <568D849B.80607@stressinduktion.org>
References: <1452094903-12934-1-git-send-email-hannes@stressinduktion.org>
 <1452094903-12934-3-git-send-email-hannes@stressinduktion.org>
 <CAEh+42j2w6t7+WNN9y0k6M5Ld+14B2txCkfLw6zwrR04+i8Xqw@mail.gmail.com>
 <568D6188.4090705@stressinduktion.org>
 <CAEh+42iA+ReWfxLHHXOx5cYCDhrFyRkFwvPqrMfbGj+UK-nxYw@mail.gmail.com>
 <568D782D.4000602@stressinduktion.org>
 <CAEh+42gOhXgB=M-nxQcGN6yGwnk3vwFEOwkAKdfE3vpLQ=LZ5w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Jesse Gross <jesse@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:60870 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751969AbcAFVSX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 16:18:23 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 26FC02037A
	for <netdev@vger.kernel.org>; Wed,  6 Jan 2016 16:18:22 -0500 (EST)
In-Reply-To: <CAEh+42gOhXgB=M-nxQcGN6yGwnk3vwFEOwkAKdfE3vpLQ=LZ5w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06.01.2016 22:01, Jesse Gross wrote:
> On Wed, Jan 6, 2016 at 12:25 PM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> The refreshes from each module are completely synchronous and don't get
>> interleaved, so as long as the driver is correctly handling the locking
>> internally rtnl lock shouldn't be needed. But as I don't know too much about
>> driver developing I can revisit this.
>>
>> As a advantage I see that the driver developers don't need to worry about
>> the rtnl lock at all when adding new events. Is this realistic?
>
> I don't think that there is much savings to be had by avoiding RTNL
> since the majority of interactions that the driver has with the stack
> involve holding it anyways.
>
> In order to do this safely without RTNL we need to have a lock in each
> driver. I don't think that this is safely handled in all cases today
> and is likely to get worse in the future. I also noticed that Geneve
> actually doesn't hold any special lock while calling into drivers from
> geneve_get_rx_port() so it is de-facto relying on RTNL. All other
> operations in the Geneve driver are protected by RTNL currently, so we
> would need to introduce a new lock to handle this as well. In effect,
> it seems like people are implicitly assuming that these operations are
> covered by RTNL since most similar things are.

Okay, on top of the v1 version I will check all drivers and add 
necessary rtnl_locks. Hopefully it works out and I don't have to defer 
calls into working queues in the drivers first.

Thanks,
Hannes
