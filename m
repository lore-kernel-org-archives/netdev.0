From: "Anton 'EvilMan' Danilov" <littlesmilingcloud@gmail.com>
Subject: Re: Using HTB over MultiQ
Date: Fri, 8 Nov 2013 18:53:10 +0400
Message-ID: <CAEzD07JwrnqeB35BiTC2ztpyei2KNDtYO8zuewicKNBwyxmOtQ@mail.gmail.com>
References: <CAEzD07+Haf-Kg52H7GsxC5XiQn2KXozHbxgL4Lvn0grhFXVFmA@mail.gmail.com>
	<1383833480.9412.58.camel@edumazet-glaptop2.roam.corp.google.com>
	<1383834021.9412.61.camel@edumazet-glaptop2.roam.corp.google.com>
	<527BA63F.7040900@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f169.google.com ([74.125.82.169]:35096 "EHLO
	mail-we0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756930Ab3KHOxP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Nov 2013 09:53:15 -0500
Received: by mail-we0-f169.google.com with SMTP id q58so2079346wes.14
        for <netdev@vger.kernel.org>; Fri, 08 Nov 2013 06:53:11 -0800 (PST)
In-Reply-To: <527BA63F.7040900@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 11/7/2013 6:20 AM, Eric Dumazet wrote:
>
> So I think you need to change the device queue selection so that it only
> depends on your filters / htb classes.
>
> Otherwise flows for a particular 'customer' might be spread on the 8
> queues, so the rate could be 8 * 1Mbit, instead of 1Mbit.

2013/11/7 John Fastabend <john.r.fastabend@intel.com>:
>
> With the multiq qdisc you could attach filter to the root qdisc and use
> skbedit to set the queue_mapping field,
>
> #tc filter add dev eth0 parent 1: protocol ip prio 1 u32 \
>         match ip dst 192.168.0.3 \
>         action skbedit queue_mapping 3
>
> if you configure the filters to map to the correct classes this would
> work.
>

I did as you adviced to me. I'm using the skbedit action with classify
filters for map the packet to assigned queue.
But i've got the another unexpected issue. u32 classifier of the root
multiq qdisc isn't setting the skb->priority value, and result of the
classifying is lost. For avoid this behaviour i'm setting priority by
the skbedit action.
After this all works as expected.
Unfortunately performance aren't improved.

Over 60 percent of 'perf top' is _raw_spin_lock function.
Speed of traffic is near 6Gbit/s, packet rate ~ 1.3 Mpps. But this
speed are limited by shaper.

Thanks for help.

-- 
Anton.
