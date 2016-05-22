From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v7 net-next 01/16] gso: Remove arbitrary checks for
 unsupported GSO
Date: Sun, 22 May 2016 14:33:53 +0200
Message-ID: <3d94c7e9-0a73-0964-8b9f-d6ec6175f0e6@stressinduktion.org>
References: <1463587584-2315623-1-git-send-email-tom@herbertland.com>
 <1463587584-2315623-2-git-send-email-tom@herbertland.com>
 <cc2e026a-6ab0-8d52-5c3d-29843c6ddf40@stressinduktion.org>
 <20160522074407.GA12660@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Tom Herbert <tom@herbertland.com>, davem@davemloft.net,
	netdev@vger.kernel.org, kernel-team@fb.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:41485 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752213AbcEVMd6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 May 2016 08:33:58 -0400
Received: from compute5.internal (compute5.nyi.internal [10.202.2.45])
	by mailout.nyi.internal (Postfix) with ESMTP id 9CBC120651
	for <netdev@vger.kernel.org>; Sun, 22 May 2016 08:33:56 -0400 (EDT)
In-Reply-To: <20160522074407.GA12660@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22.05.2016 09:44, Michael S. Tsirkin wrote:
> On Sat, May 21, 2016 at 03:02:30AM +0200, Hannes Frederic Sowa wrote:
>> Hello,
>>
>> On 18.05.2016 18:06, Tom Herbert wrote:
>>> In several gso_segment functions there are checks of gso_type against
>>> a seemingly arbitrary list of SKB_GSO_* flags. This seems like an
>>> attempt to identify unsupported GSO types, but since the stack is
>>> the one that set these GSO types in the first place this seems
>>> unnecessary to do. If a combination isn't valid in the first
>>> place that stack should not allow setting it.
>>>
>>> This is a code simplication especially for add new GSO types.
>>
>> I couldn't still wrap my head around this.
>>
>> I wonder if this is safe in case of if the packet is generated from an
>> untrusted virtual machine over virtio_net?
>>
>> Bye,
>> Hannes
> 
> I'm not sure how you use virtio_net, but neither it nor tun or macvtap
> commonly used as backends for it pass gso flags through
> from untrusted entities.

Sorry for the noise, I see the flags gets sanitized during transport.

Thanks,
Hannes
