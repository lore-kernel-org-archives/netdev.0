From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: Re: [PATCH net-next 1/2] ieee802154: sparse warnings: make symbols static
Date: Wed, 4 Jul 2012 17:38:49 +0400
Message-ID: <CAJmB2rAdDvpGhEDzBQddJBi5fJ55McN8uJEzLQiF_froR4hxVA@mail.gmail.com>
References: <1341209912-6030-1-git-send-email-alex.bluesman.smirnov@gmail.com>
	<1341209912-6030-2-git-send-email-alex.bluesman.smirnov@gmail.com>
	<1341211072.5269.0.camel@edumazet-glaptop>
	<1341211476.5269.2.camel@edumazet-glaptop>
	<1341211751.5269.6.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: davem@davemloft.net, netdev@vger.kernel.org, dbaryshkov@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:41553 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751895Ab2GDNiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jul 2012 09:38:50 -0400
Received: by lbbgm6 with SMTP id gm6so11201804lbb.19
        for <netdev@vger.kernel.org>; Wed, 04 Jul 2012 06:38:49 -0700 (PDT)
In-Reply-To: <1341211751.5269.6.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

just a several questions:

>> >
>> > static DEFINE_SPINLOCK(flist_lock);
>>
>>
>> and of course commit 768f7c7c121e80f4 (6lowpan: add missing
>> spin_lock_init() ) must be reverted.

Do I need to create 2 separate patches: one for revert and second to
initialize spinlock correctly, or I can combine these changes in one
patch?

>
> You should validate this code with LOCKDEP

Nothing was shown by LOCKDEP for 6lowpan. :-(

I've selected the following options:

-*- Spinlock and rw-lock debugging: basic checks
-*- Mutex debugging: basic checks
-*- Lock debugging: detect incorrect freeing of live locks
[*] Lock usage statistics
[*] Lock dependency engine debugging

>
> lowpan_dellink() does a spin_lock(&flist_lock);
> while same lock can be taken by lowpan_fragment_timer_expired() from
> timer irq, -> deadlock.

What would be the best way to solve this context mismatch? Can I do
something like following:
1. create some 6lowpan internal workqueue
2. replace lowpan_fragment_timer_expired() body by queue_work() with
current list_deleting routine
3. when 6lowpan is going to be deleted - I'll flush the queue and
remove all the timers and respective fragments

Alex
