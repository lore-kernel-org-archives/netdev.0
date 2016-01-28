From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next] ipvlan: inherit MTU from master device
Date: Thu, 28 Jan 2016 09:04:05 -0800
Message-ID: <CAF2d9jitKK9dBkpAUYFJtTMsw2zCP0Z+U0fEs2W7bwj2VA1rUw@mail.gmail.com>
References: <1453966408-16343-1-git-send-email-mahesh@bandewar.net> <CANn89iJXmdaq=Rc20QriH+QL8Nug_g4zRUO8BFw04pdAWQ6BEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
	David Miller <davem@davemloft.net>,
	Tim Hockin <thockin@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tim Hockins <thockins@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:34952 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967449AbcA1RE0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jan 2016 12:04:26 -0500
Received: by mail-yk0-f177.google.com with SMTP id y137so38003708yka.2
        for <netdev@vger.kernel.org>; Thu, 28 Jan 2016 09:04:25 -0800 (PST)
In-Reply-To: <CANn89iJXmdaq=Rc20QriH+QL8Nug_g4zRUO8BFw04pdAWQ6BEA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 28, 2016 at 5:13 AM, Eric Dumazet <edumazet@google.com> wrote:
> On Wed, Jan 27, 2016 at 11:33 PM, Mahesh Bandewar <mahesh@bandewar.net> wrote:
>> From: Mahesh Bandewar <maheshb@google.com>
>>
>> When we create IPvlan slave; we use ether_setup() and that
>> sets up default MTU to 1500 while the master device may have
>> lower / different MTU. Any subsequent changes to the masters'
>> MTU are reflected into the slaves' MTU setting. However if those
>> don't happen (most likely scenario), the slaves' MTU stays at
>> 1500 which could be bad.
>>
>> This change adds code to inherit MTU from the master device
>> instead of using the default value during the link initialization
>> phase.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> CC: Eric Dumazet <eric.dumazet@gmail.com>
>> CC: Tim Hockins <thockins@google.com>
>>
>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
> Two points Mahesh :
>
> 1) ipvlan_adjust_mtu() could be static, it is only used from
> drivers/net/ipvlan/ipvlan_main.c
>
Correct, I'm working on a some other (generic) changes and I could
include this suggestion  as part of that / later patch or do you
prefer it to be part of this change?

> 2) mtu_adj does not seem to be used ?
mtu_adj is set to zero so that it follows the master. The idea behind
this field was that if enhancements / changes to the IPvlan driver
(some sort of built-in encapsulation etc.) is added, this can be set
to that magic value so that changes to master will still allow slaves
to follow it without compromising the built-in mechanism.
