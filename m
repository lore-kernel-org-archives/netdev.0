From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH next 0/4] bonding: winter cleanup
Date: Wed, 22 Feb 2017 11:23:13 -0800
Message-ID: <CAF2d9ji69=q-u+80Hj1y45YSjN9Tq4M4OBvbjNEWShiayN8U2A@mail.gmail.com>
References: <20170222010816.9676-1-mahesh@bandewar.net> <20170222075815.GA1665@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Veaceslav Falico <vfalico@gmail.com>,
        Nikolay Aleksandrov <nikolay@redhat.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f52.google.com ([209.85.214.52]:36298 "EHLO
        mail-it0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934991AbdBVTYw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 14:24:52 -0500
Received: by mail-it0-f52.google.com with SMTP id h10so139648468ith.1
        for <netdev@vger.kernel.org>; Wed, 22 Feb 2017 11:23:41 -0800 (PST)
In-Reply-To: <20170222075815.GA1665@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 11:58 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Feb 22, 2017 at 02:08:16AM CET, mahesh@bandewar.net wrote:
>>From: Mahesh Bandewar <maheshb@google.com>
>>
>>Few cleanup patches that I have accumulated over some time now.
>>
>>(a) First two patches are basically to move the work-queue initialization
>>    from every ndo_open / bond_open operation to once at the beginning while
>>    port creation. Work-queue initialization is an unnecessary operation
>>    for every 'ifup' operation. However we have some mode-specific work-queues
>>    and mode can change anytime after port creation. So the second patch is
>>    to ensure the correct work-handler is called based on the mode.
>>
>>(b) Third patch is simple and straightforward that removes hard-coded value
>>    that was added into the initial commit and replaces it with the default
>>    value configured.
>>
>>(c) The final patch in the series removes the unimplemented "port-moved" state
>>    from the LACP state machine. This state is defined but never set so
>>    removing from the state machine logic makes code little cleaner.
>>
>>Note: None of these patches are making any functional changes.
>>
>>Mahesh Bandewar (4):
>
> Mahesh. I understand that you are still using bonding. What's stopping
> you from using team instead?
>
Let me just say this, if it was trivial enough, we'd have done with it
by now. :)

> Isn't about the time to start deprecate process of bonding? :O
>
>
>>  bonding: restructure arp-monitor
>>  bonding: initialize work-queues during creation of bond
>>  bonding: remove hardcoded value
>>  bonding: remove "port-moved" state that was never implemented
>>
>> drivers/net/bonding/bond_3ad.c  | 11 +++--------
>> drivers/net/bonding/bond_main.c | 42 ++++++++++++++++++++++++++++-------------
>> 2 files changed, 32 insertions(+), 21 deletions(-)
>>
>>--
>>2.11.0.483.g087da7b7c-goog
>>
