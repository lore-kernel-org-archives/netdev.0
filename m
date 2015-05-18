From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 2/6] neigh: fix a possible leak issue of neigh
 entry
Date: Mon, 18 May 2015 13:55:09 +0800
Message-ID: <55597EBD.8040002@windriver.com>
References: <1431672946-300-1-git-send-email-ying.xue@windriver.com>	 <1431672946-300-3-git-send-email-ying.xue@windriver.com>	 <1431691962.27831.90.camel@edumazet-glaptop2.roam.corp.google.com>	 <20150515.113950.1408734283430265055.davem@davemloft.net>	 <55595B64.70702@windriver.com> <1431925082.621.31.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<alexei@purestorage.com>, <joern@purestorage.com>, <ja@ssi.bg>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:39727 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752055AbbERFza (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 01:55:30 -0400
In-Reply-To: <1431925082.621.31.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/18/2015 12:58 PM, Eric Dumazet wrote:
> On Mon, 2015-05-18 at 11:24 +0800, Ying Xue wrote:
> 
>> If the issue of "neigh use-after-free" is fixed by the first patch although you
>> said the atomic_read() was not safe for us, is the patch still wrong? If it's
>> really wrong, can you please give more detailed explanation to help me
>> understand why the change is wrong and but why a similar timer usage in
>> sk_reset_timer() is not wrong?
> 
> Why do you believe sk_reset_timer() would be wrong ?
> 

Sorry, I don't think sk_reset_timer() is wrong, instead I suppose
neigh_add_timer() is wrong :)

> Difference between neigh_add_timer() and sk_reset_timer() is very
> simple :
> 
> neigh_add_timer() must be called while the timer is not yet armed.
> 

In case that the caller of neigh_add_timer() attempts to modify an active timer
due to a bug or something wrong else, why not prevent neigh_add_timer() from
taking neigh refcnt beside posting a warning message?

So, exactly speaking, we cannot say neigh_add_timer() is completely wrong
regarding your mentioned above assumption that neigh timer is absolutely not
armed when neigh_add_timer() is called. But we can say its behaviour is not
designed very well. From this point, the patch seems still a bit valuable for us.

Regards,
Ying

> sk_reset_timer() can be called while timer is already armed.
> 
> You are changing neigh_add_timer() for no good reason, just because you
> want it to be 'like sk_reset_timer()' ?
> 
> 
> 
> 
> 
