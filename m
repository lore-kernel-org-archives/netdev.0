From: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] codel: add forgotten inline to functions in header file
Date: Thu, 11 Feb 2016 08:09:34 -0800
Message-ID: <CAA93jw5=6zxg8P77VkgDEZFM+u+5zHBuW5ODoWqFV59PoSWtgQ@mail.gmail.com>
References: <1455199701-25767-1-git-send-email-emmanuel.grumbach@intel.com>
	<1455201038.19473.12.camel@edumazet-glaptop2.roam.corp.google.com>
	<0BA3FCBA62E2DC44AF3030971E174FB32EA0E6FD@hasmsx107.ger.corp.intel.com>
	<1455203555.19473.14.camel@edumazet-glaptop2.roam.corp.google.com>
	<0BA3FCBA62E2DC44AF3030971E174FB32EA0E809@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <0BA3FCBA62E2DC44AF3030971E174FB32EA0E809-Jy8z56yoSI9wl47ZQwxUxrfspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 11, 2016 at 7:29 AM, Grumbach, Emmanuel
<emmanuel.grumbach-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:
>
>
> On 02/11/2016 05:12 PM, Eric Dumazet wrote:
>> On Thu, 2016-02-11 at 15:05 +0000, Grumbach, Emmanuel wrote:
>>
>>
>>> Yeah :) codel_should_drop seemed very long indeed... I wanted to use the
>>> codel_get_time and associated utils (_before, _after) in iwlwifi.
>>> They're better than jiffies... So maybe I can just copy that code to
>>> iwlwifi.

Definately better than jiffies.

>>
>> You certainly can submit a patch adding the inline, but not on all
>> functions present in this file ;)
>>
>> Thanks !
>>
>
> Actually... All I need *has* the inline, but if I include codel.h,
> codel_dequeue is defined but not used and you definitely don't want to
> inline that one. So I guess the only other option I have is to split
> that header file which I don't think is really worth it. So, unless you
> object it, I'll just copy the code.

I think it is best to start with another base implementation of codel
for wifi, yes.

What I think is the currently best performing codel implementation (on
the wire, for ethernet) we have is in:

https://github.com/dtaht/bcake/codel5.h

which has a few differences from eric's implementation (64 bit
timestamps, inlining, not a lot of cpu profiling on it - still aiming
for algorithmic correctness here, it is closer to the original
paper... We'd used a different means of injecting the callback in it,
too)

The one currently in the main cake had issues in the last test round
but has been updated since. (sch_cake is also on github).

In neither case it is the right thing for wifi either.

the "starting plan" such as it was was to get to "one aggregate in the
hardware, one in the driver, one ready to be formed on the completion
interrupt", and pull a smoothed service time from start to completion
interrupt to dynamically modify the codel target. (other headaches,
like multicast, abound).

(It's the per station queue + fq as close to the hardware as possible
that matters most, IMHO.)

>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
