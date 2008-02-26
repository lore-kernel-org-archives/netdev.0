From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 26 Feb 2008 13:03:34 +0000
Message-ID: <20080226130334.GA16049@ff.dom.local>
References: <20080225215837.GA3281@ami.dom.local> <47C402A2.8040401@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.189]:26429 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752425AbYBZNCg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2008 08:02:36 -0500
Received: by mu-out-0910.google.com with SMTP id i10so3460080mue.5
        for <netdev@vger.kernel.org>; Tue, 26 Feb 2008 05:02:32 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47C402A2.8040401@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 26, 2008 at 12:14:26PM +0000, James Chapman wrote:
> Jarek Poplawski wrote:
>> Jarek Poplawski wrote, On 02/25/2008 02:39 PM:
>> ...
>>> Hmm... Wait a minute! But on the other hand David has written about
>>> his cons here, and it looks reasonable: this place would be fixed,
>>> but some others can start reports like this. Maybe, it's better to
>>> analyze yet if it's really so hard to eliminate taking this lock
>>> on the xmit path?
>>
>> James, I wonder if you could try to test this patch below?
>> ip_queue_xmit() seems to do proper things with __sk_dst_check(), and
>> if some other functions don't behave similarly lockdep should tell.
>> I think, you could test it with your "locks to _bh" patch (without
>> pppol2tp_xmit() part), and maybe with my sock.c lockdep patch (it
>> should help lockdep to see these locks a bit more distinctly).
>
> I found the same thing and was running a variant of your patch last  
> night; rather than set skb->dst to NULL though, I use __sk_dst_get() and  
> let ip_queue_xmit() do the route lookup if it returns NULL. But this has  
> the same symptoms as the code I tried a few days ago - no lockdep errors  
> but a system lockup after up to several hours. Nothing is logged in the  
> syslog.

I guess you are going to try this together with this sk_dst_lock with
bh patch too. If it's possible I'd suggest to try this skb->dst = NULL
as well (__sk_dst_get instead of __sk_dst_check seems to be too racy).

> Luckily, I'm in the lab where my two borrowed servers are today so I  
> have access to their consoles. Hopefully I'll be able to find out why  
> there are hanging. Btw, they don't hang if I disable irqs around the  
> ppp_input() call.

...and disabling bh instead isn't enough, BTW?

> Will update you later.

Thanks,
Jarek P.
