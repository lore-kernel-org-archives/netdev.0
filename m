From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Tue, 19 Feb 2008 10:30:47 +0000
Message-ID: <20080219103047.GA3898@ff.dom.local>
References: <47B17BCD.2070903@katalix.com> <20080214130016.GA2583@ff.dom.local> <47BA0214.40703@katalix.com> <20080218.202934.79548477.davem@davemloft.net> <47BA9B50.8040404@katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.187]:23150 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753687AbYBSK35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 05:29:57 -0500
Received: by mu-out-0910.google.com with SMTP id i10so2068104mue.5
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2008 02:29:55 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <47BA9B50.8040404@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 19, 2008 at 09:03:12AM +0000, James Chapman wrote:
> David Miller wrote:
>> From: James Chapman <jchapman@katalix.com>
>> Date: Mon, 18 Feb 2008 22:09:24 +0000
>>
>>> Here's a new version of the patch. The patch avoids disabling irqs
>>> and fixes the sk_dst_get() usage that DaveM mentioned. But even with
>>> this patch, lockdep still complains if hundreds of ppp sessions are
>>> inserted into a tunnel as rapidly as possible (lockdep trace is
>>> below). I can stop these errors by wrapping the call to ppp_input()
>>> in pppol2tp_recv_dequeue_skb() with local_irq_save/restore. What is
>>> a better fix?
>>
>> Firstly, let's fix one thing at a time.  Leave the sk_dst_get()
>> thing alone until we can prove that it's part of the lockdep
>> traces.
>
> In reproducing the problem, I obtained several lockdep traces that  
> implicated sk_dst_get().

As a matter of fact I missed just that kind information on previous
lockdep report, so if you could send them too this should be still
helpful.

...
> I agree. I'm seeking advice on what the underlying cause is of this new  
> trace.

IMHO, just like I wrote earlier, the main problem is in ppp_generic(),
especially ppp_connect_channel(), where main tx & rx locks are used.
I didn't know enough about this sk_dst_lock traces yet. I hope I could
help with this, but after these changes I need some time to figure
this out again.

Jarek P.
