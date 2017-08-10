From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: Re: [PATCH RFC net-next] net: Allow name change of IFF_UP interfaces
Date: Thu, 10 Aug 2017 10:41:23 +0200
Message-ID: <871sojyfv0.fsf@vitty.brq.redhat.com>
References: <20170809104202.30959-1-vkuznets@redhat.com>
        <CAPA1RqA0q3W-3PsqDpY8_xiBB18SCWTV1gT+BKOTqQfAA5D8Fg@mail.gmail.com>
        <87efskye74.fsf@vitty.brq.redhat.com> <20170809161027.GA28694@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: ???????????? <hideaki.yoshifuji@miraclelinux.com>,
        network dev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>,
        Stephen Hemminger <stephen@networkplumber.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809161027.GA28694@lunn.ch> (Andrew Lunn's message of "Wed,
        9 Aug 2017 18:10:27 +0200")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Lunn <andrew@lunn.ch> writes:

>> I understand the 'legacy' concern but at the same time we don't want to
>> have aftificial limitations too. Name change, in particular, doesn't
>> happen 'under the hood' -- someone privileged enough needs to request
>> the change.
>> 
>> Can you think of any particular real world scenarios which are broken by
>> the change?
>
> How about:
>
> man 8 dhclient-script
>
> The interface name is passed in $interface to the scripts. Do we get
> the old name or the new name? I suspect scripts are going to break if
> they are given the old name, which no longer exists.

Yes but why would anyone change interface name while dhclient-script is
running? Things will also go wrong if you try bringing interface down
during the run or do some other configuration, right? Running multiple
configuration tools at the same moment is a bad idea, you never know
what you're gonna end up with. 

As I see it, checks in kernel we have are meant to protect kernel
itself, not to disallow all user<->kernel interactions leading to
imperfect result.

(AFAIU) If we remove the check nothing is going to change: udev will
still be renaming interfaces before bringing them up. In netvsc case
users are not supposed to configure the VF interface at all, it just
becomes a slave of netvsc interface.

-- 
  Vitaly
