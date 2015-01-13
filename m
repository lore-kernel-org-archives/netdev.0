From: YOSHIFUJI Hideaki <hideaki.yoshifuji@miraclelinux.com>
Subject: Re: why are IPv6 addresses removed on link down
Date: Tue, 13 Jan 2015 20:58:43 +0900
Message-ID: <54B50873.4090907@miraclelinux.com>
References: <54B4A7E4.7030301@gmail.com> <20150112231021.316648e3@urahara> <1421145346.13626.12.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com,
	David Ahern <dsahern@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og128.obsmtp.com ([64.18.2.121]:47923 "HELO
	exprod7og128.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752448AbbAMMFB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 07:05:01 -0500
Received: by mail-pd0-f169.google.com with SMTP id z10so3168697pdj.0
        for <netdev@vger.kernel.org>; Tue, 13 Jan 2015 04:05:01 -0800 (PST)
In-Reply-To: <1421145346.13626.12.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hannes Frederic Sowa wrote:
> On Mo, 2015-01-12 at 23:10 -0800, Stephen Hemminger wrote:
>> On Mon, 12 Jan 2015 22:06:44 -0700
>> David Ahern <dsahern@gmail.com> wrote:
>>
>>> We noticed that IPv6 addresses are removed on a link down. e.g.,
>>>     ip link set dev eth1
>>>
>>>
>>> Looking at the code it appears to be this code path in addrconf.c:
>>>
>>>           case NETDEV_DOWN:
>>>           case NETDEV_UNREGISTER:
>>>                   /*
>>>                    *      Remove all addresses from this interface.
>>>                    */
>>>                   addrconf_ifdown(dev, event != NETDEV_DOWN);
>>>                   break;
>>>
>>> IPv4 addresses are NOT removed on a link down. Is there a particular
>>> reason IPv6 addresses are?
>>>
>>> Thanks,
>>> David
>>
>> See RFC's which describes how IPv6 does Duplicate Address Detection.
>> Address is not valid when link is down, since DAD is not possible.
>
> It should be no problem if the kernel would reacquire them on ifup and
> do proper DAD. We simply must not use them while the interface is dead
> (also making sure they don't get used for loopback routing).
>
> The problem the IPv6 addresses get removed is much more a historical
> artifact nowadays, I think. It is part of user space API and scripts
> deal with that already.

We might have another "detached" state which essintially drops
outgoing packets while link is down.  Just after recovering link,
we could start receiving packet from the link and perform optimistic
DAD. And then, after it succeeds, we may start sending packets.

Since "detached" state is like the state just before completing
Optimistic DAD, it is not so difficult to implement this extended
behavior, I guess.

-- 
Hideaki Yoshifuji <hideaki.yoshifuji@miraclelinux.com>
Technical Division, MIRACLE LINUX CORPORATION
