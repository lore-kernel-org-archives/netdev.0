From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net] bonding: Fix bonding crash
Date: Fri, 2 Sep 2016 19:15:07 +0200
Message-ID: <20160902171507.GB1768@nanopsycho.orion>
References: <1472793514-31850-1-git-send-email-mahesh@bandewar.net>
 <20160902075241.GA1814@nanopsycho>
 <1472823200.5439.15.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160902162513.GA1768@nanopsycho.orion>
 <1472834257.5439.42.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAF2d9jjEDhAH_649DigLz1-cikD6CmqancuyFL+5HbgJieYDtw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Jay Vosburgh <j.vosburgh@gmail.com>,
        Andy Gospodarek <gospo@cumulusnetworks.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        David Miller <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar
         =?utf-8?B?KOCkruCkueClh+CktiDgpKzgpILgpKHgpYfgpLXgpL4=?=
         =?utf-8?B?4KSwKQ==?= <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36093 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932236AbcIBRPL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:15:11 -0400
Received: by mail-wm0-f45.google.com with SMTP id c133so39199642wmd.1
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 10:15:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAF2d9jjEDhAH_649DigLz1-cikD6CmqancuyFL+5HbgJieYDtw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fri, Sep 02, 2016 at 07:08:54PM CEST, maheshb@google.com wrote:
>On Fri, Sep 2, 2016 at 9:37 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Fri, 2016-09-02 at 18:25 +0200, Jiri Pirko wrote:
>>
>>> Understand the reason. All I say is we tried hard (I surely did) in
>>> the past to remove bonding specific quirks and now we are adding one.
>>> And the simple reason is that the code is such a mess.
>>>
>I would not qualify this as bonding specific change! The check of you can
>really use the interface is simple enough, and can be used by other virtual
>drivers (e.g. macvlan, ipvlan, vrf etc.). Waiting until
>rx_handler_register() can be
>called in your code and then try to do rollback is bad. Also doing
>register() early
>has it's own consequences. On contrary, I would argue that this is much cleaner.

Fair enough. Would be great to do this in all other rx_handler users so
we are consistent. Thanks!


>
>Agreed that bonding-driver has become a monster but that doesn't mean we
>should not fix issues. This argument would be valid when we are
>dealing with last
>couple installations / use cases of bonding and everyone else has moved to
>alternatives. Unfortunately we are not there yet :(
>
>>> Just use team instead and you'll be fine. You can "google" it :)
>>
>> Sure, please join _our_ team and make all the needed changes in user
>> land.
>>
>:) Cannot put it more eloquently than Eric did but we would (in
>theory) love to move
>to team-driver, but logistics don't support this (yet!).
>
>> The kernel part of it is epsilon compared to all the control part (ie
>> talk to the various Google switches.), and monitoring.
>>
>> I am fine to leave the bug in upstream bonding driver, if you really
>> want to force people out of bonding land !
>>
>> Here an automated test simply used macvlan and did not remove the
>> macvlan before enslaving the netdev again in a bonding, we already fixed
>> the test, because it is faster than deploying new kernels anyway.
>>
>>
>>
