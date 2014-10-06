From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 1/3] net: sched: af_packet support for direct
 ring access
Date: Sun, 05 Oct 2014 18:12:34 -0700
Message-ID: <5431EC82.7010305@gmail.com>
References: <20141006000629.32055.2295.stgit@nitbit.x32> <20141006002951.GA24376@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dborkman@redhat.com, gerlitz.or@gmail.com,
	hannes@stressinduktion.org, netdev@vger.kernel.org,
	john.ronciak@intel.com, amirv@mellanox.com, eric.dumazet@gmail.com,
	danny.zhou@intel.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:44580 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751809AbaJFBMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Oct 2014 21:12:51 -0400
Received: by mail-ob0-f178.google.com with SMTP id wn1so3167771obc.37
        for <netdev@vger.kernel.org>; Sun, 05 Oct 2014 18:12:51 -0700 (PDT)
In-Reply-To: <20141006002951.GA24376@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2014 05:29 PM, Florian Westphal wrote:
> John Fastabend <john.fastabend@gmail.com> wrote:
>> There is one critical difference when running with these interfaces
>> vs running without them. In the normal case the af_packet module
>> uses a standard descriptor format exported by the af_packet user
>> space headers. In this model because we are working directly with
>> driver queues the descriptor format maps to the descriptor format
>> used by the device. User space applications can learn device
>> information from the socket option PACKET_DEV_DESC_INFO which
>> should provide enough details to extrapulate the descriptor formats.
>> Although this adds some complexity to user space it removes the
>> requirement to copy descriptor fields around.
>
> I find it very disappointing that we seem to have to expose such
> hardware specific details to userspace via hw-independent interface.
>

Well it was only for convenience if it doesn't fit as a socket
option we can remove it. We can look up the device using the netdev
name from the bind call. I see your point though so if there is
consensus that this is not needed that is fine.

> How big of a cost are we talking about when you say that it 'removes
> the requirement to copy descriptor fields'?
>

This was likely a poor description. If you want to let user space
poll on the ring (without using system calls or interrupts) then
I don't see how you can _not_ expose the ring directly complete with
the vendor descriptor formats.

> Thanks,
> Florian
>


-- 
John Fastabend         Intel Corporation
