From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net] net: poll tx timeout only on active tx queues
Date: Fri, 1 Jul 2016 15:03:00 +0300
Message-ID: <CALzJLG9tiqPUe=h+OhTSqaS1ULkOtG3ycaZQXGrvtbgL3deH6g@mail.gmail.com>
References: <1467295085-9204-1-git-send-email-saeedm@mellanox.com>
 <1467296892.11238.24.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALzJLG-pjeZnOQ3FfZMLCz5KC-eXWWrTZS4yNi-+UYY=2T549A@mail.gmail.com>
 <CO2PR11MB00889A8F46E66124C99E43DE97250@CO2PR11MB0088.namprd11.prod.outlook.com>
 <1467350290.11238.31.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Mohamad Haj Yahia <mohamad@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:33567 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750715AbcGAMDU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 08:03:20 -0400
Received: by mail-qk0-f171.google.com with SMTP id o76so84044185qke.0
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 05:03:20 -0700 (PDT)
In-Reply-To: <1467350290.11238.31.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 1, 2016 at 8:18 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Fri, 2016-07-01 at 04:50 +0000, Yuval Mintz wrote:
>> > currently all the device driver call  netif_tx_start_all_queues(dev)
>> > on open to W/A this issue. which is strange since only
>> > real_num_tx_queues are active.
>>
>> You could also argue that netif_tx_start_all_queues() should
>> only enable the real_num_tx_queues.
>> [Although that would obviously cause all drivers to reach the
>> 'problem' you're currently fixing].
>
> Yep. Basically what I pointed out.
>
> It seems inconsistent to have loops using num_tx_queues, and others
> using real_num_tx_queues.
>
> Instead of 'fixing' one of them, we should take a deeper look, even if
> the change looks fine.
>
> num_tx_queues should be used in code that runs once, like
> netdev_lockdep_set_classes(), but other loops should probably use
> real_num_tx_queues.
>
> Anyway all these changes should definitely target net-next, not net
> tree.
>

Thank you Eric and Yuval,

Although i slightly disagree, this patch is good as is, even with the
inconsistency, which is there due to a bad design.
I don't' see why new drivers need to keep copy from old wrong
implementations and workarounds.

But for the long term, you have a point.
We will consider a deeper fix for net-next as you suggested, and drop
this temporary fix.

Thanks
Saeed.
