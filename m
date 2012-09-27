From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Subject: Re: mlx4: dropping multicast packets at promisc leave
Date: Thu, 27 Sep 2012 17:37:25 -0300
Message-ID: <5064B905.6090906@redhat.com>
References: <505A66CC.8010701@redhat.com> <505B1874.3040904@mellanox.com> <505B3088.7090908@redhat.com> <505CB2BD.4080402@redhat.com>
Reply-To: mleitner@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2420 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697Ab2I0Uhc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Sep 2012 16:37:32 -0400
In-Reply-To: <505CB2BD.4080402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/21/2012 03:32 PM, Marcelo Ricardo Leitner wrote:
> On 09/20/2012 12:04 PM, Marcelo Ricardo Leitner wrote:
>> On 09/20/2012 10:21 AM, Or Gerlitz wrote:
>>> On 20/09/2012 03:43, Marcelo Ricardo Leitner wrote:
>>>> I have a report that our mlx4 driver (RHEL 6.3) is dropping multicast
>>>> packets when NIC leaves promisc mode. It seems this is being cause due
>>>> to the new steering mode that took place near by commit
>>>> 1679200f91da6a054b06954c9bd3eeed29b6731f. As it seems, the new
>>>> steering mode needs more commands/time to leave the promisc mode,
>>>> which may be leading to packet drops.
>>>
>>> Marcelo,
>>>
>>> The commit you point on below 6d19993 "net/mlx4_en: Re-design multicast
>>> attachments flow" makes sure to avoid
>>> doing extra firmware comments and not leave a window in time where
>>> "correct" addresses are not attached. Its hard to say what's the case on
>>> that RHEL 6.3 system, it would be very helpful through if you manage to
>>> reproduce the problem on an upstream kernel -- BTW you didn't say on
>>
>> Okay, I understand that the commit prevents a window. I may be missing
>> something, but isn't there another one in there? Between:
>> mlx4_SET_MCAST_FLTR MLX4_MCAST_DISABLE and
>> mlx4_SET_MCAST_FLTR MLX4_MCAST_ENABLE
>> because mlx4_multicast_promisc_remove() was called just before those.
>> Otherwise I don't how is the NIC would be receiving multicast packets in
>> there.
>>
> ....
>> And then I tried 3 additional patches applied at once:
>> - 60d31c1475f2 "net/mlx4_core: Looking for promiscuous entries on the
>> correct port"
>> - f1f75f0 - mlx4: attach multicast with correct flag
>> - Yes, this one wasn't in 2.6.32-279.el6.
>> - 6d19993 - net/mlx4_en: Re-design multicast attachments flow
>>
>> And they still reported drops.

Well, neither me nor they could reproduce the drops at promisc exit 
anymore. It's hard to chase a ghost, you know. I'll still track that cpu 
usage, but it seems unrelated to the driver at first glance.

Thank you for your support Or, appreciated.

Regards,
Marcelo
