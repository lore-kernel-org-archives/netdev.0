From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [RFC PATCH] net, rps: bypass enqueue_to_backlog()
Date: Wed, 18 Dec 2013 22:11:03 +0800
Message-ID: <CAEH94Lh-Dujb9YbpFK0kTu2O3pGSf16rXwCWFWBE50K_4geHnA@mail.gmail.com>
References: <1387371816-32476-1-git-send-email-zwu.kernel@gmail.com>
	<1387374979.19078.309.camel@edumazet-glaptop2.roam.corp.google.com>
	<1387375442.19078.310.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f49.google.com ([209.85.219.49]:37087 "EHLO
	mail-oa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753536Ab3LROLE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:11:04 -0500
Received: by mail-oa0-f49.google.com with SMTP id i4so8215979oah.36
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:11:03 -0800 (PST)
In-Reply-To: <1387375442.19078.310.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 18, 2013 at 10:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-12-18 at 05:56 -0800, Eric Dumazet wrote:
>> On Wed, 2013-12-18 at 21:03 +0800, Zhi Yong Wu wrote:
>> > From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> >
>> > When local cpu is just target cpu which will handle network soft irq,
>> > the packet should be directly injected to network stack, by bypassing
>> > enqueue_to_backlog(), it can speed up the packet processing.
>> >
>> > HI, guys
>> >
>> > I checked the first several versions of RPS patch which seemed to have
>> > this condition determination, but why was it removed later? Do i miss
>> > anything? if yes, please correct me, thanks.
>> >
>> > Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> > ---
>>
>> Hmm... Could you elaborate ?
>>
>> At which point do you think this condition was tested or removed ?
>>
>> I think the idea was to drain NIC RX queues as fast as possible, then :
>>
>> - Send the IPI to remote cpus
>> - process our queue in parallel with other cpus processing their own
>> queue.
>>
>> If we process our packets through whole stack, packets for other cpus
>> will have a fair amount of extra latency.
>>
>> Thats a tradeoff I suppose.
>>
>
> Also note that going through the backlog permits thinks like
>
> 99bbc70741903c0  ("rps: selective flow shedding during softnet
> overflow"
it makes sense, but if cpu < 0, some packets seems to bypass the flow
shedding stuff, That is, the flow limit will be not so accurate,
right?

>
>
>



-- 
Regards,

Zhi Yong Wu
