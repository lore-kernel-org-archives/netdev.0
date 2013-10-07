From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH 1/2] net: Add layer 2 hardware acceleration operations
 for macvlan devices
Date: Mon, 07 Oct 2013 15:39:01 -0700
Message-ID: <52533805.2010607@gmail.com>
References: <20131007.155214.2232375975382665567.davem@davemloft.net> <20131007212000.GA1596@hmsreliant.think-freely.org> <20131007.173433.163556658910279518.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:41247 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751881Ab3JGWjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Oct 2013 18:39:13 -0400
Received: by mail-ie0-f174.google.com with SMTP id u16so17190313iet.19
        for <netdev@vger.kernel.org>; Mon, 07 Oct 2013 15:39:13 -0700 (PDT)
In-Reply-To: <20131007.173433.163556658910279518.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/07/2013 02:34 PM, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 7 Oct 2013 17:20:00 -0400
>
>> Thats me experimenting.  I was thinking that origionally this functionality
>> might be grouped separately, so that we could handle it independently of the
>> standard network device operations (you might have noticed in v1 of my patch I
>> had a size_t variable in there, so I thought the separation might be
>> organizationally nice).  It was also something I was tinkering with for
>> potential future work to support other data plane accelerators (like the FM6000
>> switch chip from intel) in a manner that didn't pollute the more typical host network
>> devices.  Like I said though, just experimenting at the moment....
>

We can do something like the dcbnl ops and add another pointer off
the net device structure and then use the skb->dev field to find the
correct set of ops? This seems like the simplest option to me and
isolates the ops structure.

Is there some information loss from hanging it off the netdevice
structure vs the skb? I can't see any.

> Can these dataplane devices still act like a normal networking port and
> send and receive packets at the host level?
>

Yes they act like normal networking ports except for there is a
switching component in the hardware. These patches are not looking at
virtual or multiple physical functions at the moment.

> If yes, that would be an extremely strong argument for netdev_ops.

I agree.


-- 
John Fastabend         Intel Corporation
