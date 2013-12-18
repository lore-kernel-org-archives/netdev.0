From: Zhi Yong Wu <zwu.kernel@gmail.com>
Subject: Re: [RFC PATCH] net, rps: bypass enqueue_to_backlog()
Date: Wed, 18 Dec 2013 22:20:48 +0800
Message-ID: <CAEH94LiX640J_L+ZACj8d5g3xVygUPT-K2_MFOj8-w6S3G=hUQ@mail.gmail.com>
References: <1387371816-32476-1-git-send-email-zwu.kernel@gmail.com>
	<1387374979.19078.309.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:35811 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754944Ab3LROUt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Dec 2013 09:20:49 -0500
Received: by mail-ob0-f182.google.com with SMTP id wp4so7933159obc.41
        for <netdev@vger.kernel.org>; Wed, 18 Dec 2013 06:20:48 -0800 (PST)
In-Reply-To: <1387374979.19078.309.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

thanks for your explanation.

by the way, pls ignore this patch, thanks.

On Wed, Dec 18, 2013 at 9:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2013-12-18 at 21:03 +0800, Zhi Yong Wu wrote:
>> From: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>>
>> When local cpu is just target cpu which will handle network soft irq,
>> the packet should be directly injected to network stack, by bypassing
>> enqueue_to_backlog(), it can speed up the packet processing.
>>
>> HI, guys
>>
>> I checked the first several versions of RPS patch which seemed to have
>> this condition determination, but why was it removed later? Do i miss
>> anything? if yes, please correct me, thanks.
>>
>> Signed-off-by: Zhi Yong Wu <wuzhy@linux.vnet.ibm.com>
>> ---
>
> Hmm... Could you elaborate ?
>
> At which point do you think this condition was tested or removed ?
>
> I think the idea was to drain NIC RX queues as fast as possible, then :
>
> - Send the IPI to remote cpus
> - process our queue in parallel with other cpus processing their own
> queue.
>
> If we process our packets through whole stack, packets for other cpus
> will have a fair amount of extra latency.
>
> Thats a tradeoff I suppose.
>
>



-- 
Regards,

Zhi Yong Wu
