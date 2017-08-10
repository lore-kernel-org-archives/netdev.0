From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Thu, 10 Aug 2017 12:01:46 +0200
Message-ID: <87poc3wxkl.fsf@vitty.brq.redhat.com>
References: <20170809104202.30959-1-vkuznets@redhat.com>
        <CAPA1RqA0q3W-3PsqDpY8_xiBB18SCWTV1gT+BKOTqQfAA5D8Fg@mail.gmail.com>
        <87efskye74.fsf@vitty.brq.redhat.com> <20170809161027.GA28694@lunn.ch>
        <871sojyfv0.fsf@vitty.brq.redhat.com>
        <1502355817.4936.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Lunn <andrew@lunn.ch>, network dev <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:17070 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751416AbdHJKBt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Aug 2017 06:01:49 -0400
In-Reply-To: <1502355817.4936.9.camel@edumazet-glaptop3.roam.corp.google.com>
        (Eric Dumazet's message of "Thu, 10 Aug 2017 02:03:37 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Thu, 2017-08-10 at 10:41 +0200, Vitaly Kuznetsov wrote:
>> Andrew Lunn <andrew@lunn.ch> writes:
>> 
>> >> I understand the 'legacy' concern but at the same time we don't want to
>> >> have aftificial limitations too. Name change, in particular, doesn't
>> >> happen 'under the hood' -- someone privileged enough needs to request
>> >> the change.
>> >> 
>> >> Can you think of any particular real world scenarios which are broken by
>> >> the change?
>> >
>> > How about:
>> >
>> > man 8 dhclient-script
>> >
>> > The interface name is passed in $interface to the scripts. Do we get
>> > the old name or the new name? I suspect scripts are going to break if
>> > they are given the old name, which no longer exists.
>> 
>> Yes but why would anyone change interface name while dhclient-script is
>> running? Things will also go wrong if you try bringing interface down
>> during the run or do some other configuration, right? Running multiple
>> configuration tools at the same moment is a bad idea, you never know
>> what you're gonna end up with. 
>> 
>> As I see it, checks in kernel we have are meant to protect kernel
>> itself, not to disallow all user<->kernel interactions leading to
>> imperfect result.
>> 
>> (AFAIU) If we remove the check nothing is going to change: udev will
>> still be renaming interfaces before bringing them up. In netvsc case
>> users are not supposed to configure the VF interface at all, it just
>> becomes a slave of netvsc interface.
>
> Are we sending an event if device name is changed ?
>

We are - rtnetlink_event() does the job. We, however, don't have a
special IFLA_EVENT_* for name change and end up with IFLA_EVENT_NONE.

> If yes, your patch is fine.
>
> If not, daemons would not be aware the need to refresh their view of the
> world.

Yes but AFAIU daemons may need to do the same refresh when the interface
is down too (and, hopefully, they do it already).

-- 
  Vitaly
