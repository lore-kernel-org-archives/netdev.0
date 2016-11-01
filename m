From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH net-next 5/5] ipv6: Compute multipath hash for forwarded ICMP errors from offending packet
Date: Tue, 01 Nov 2016 17:26:22 +0100
Message-ID: <878tt3np3l.fsf@redhat.com>
References: <20161101.113505.1429989348222226550.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: tom@herbertland.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <20161101.113505.1429989348222226550.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Nov 01, 2016 at 03:35 PM GMT, David Miller wrote:
> From: Jakub Sitnicki <jkbs@redhat.com>
> Date: Tue, 01 Nov 2016 16:13:51 +0100
>
>> On Mon, Oct 31, 2016 at 07:15 PM GMT, David Miller wrote:
>>> From: Jakub Sitnicki <jkbs@redhat.com>
>>> Date: Sun, 30 Oct 2016 14:03:11 +0100
>>>
>>>> 2) ensure the flow labels used in both directions are the same (either
>>>>    reflected by one side, or fixed, e.g. not used and set to 0), so that
>>>>    the 4-tuple we hash over when forwarding, <src addr, dst addr, flow
>>>>    label, next hdr>, is the same both ways, modulo the order of
>>>>    addresses.
>>>
>>> Even Linux, by default, does not do reflection.
>>>
>>> See the flowlabel_consistency sysctl, which we set by default to '1'.
>> 
>> Yes, unfortunately, if Linux-based hosts are used as sending/receiving
>> IPv6, ICMP error forwarding will not work out of the box. Users will be
>> burdened with adjusting the runtime network stack config, as you point
>> out, or otherwise instructing the apps to set the flow label,
>> e.g. traceroute6 -I <flow label> ...
>
> I'm pretty sure that sysctl default was choosen intentionally, and we
> actively are _encouraging_ the world to not depend upon reflection in
> any way, shape, or form.
>
> And it's kind of pointless to suggest a facility that can't work with
> Linux endpoints out of the box.
>
> This was the point I'm trying to make.
>
> If the intentions of that sysctl default does pan out, the idea is for
> the world to move towards arbitrary flow label settings, even perhaps
> changing over time.  The intention is to make this more, not less,
> common.  And the idea is to give maximum flexibility for endpoints to
> set these flow labels, in order to increase entropy wherever possible.
>
> I have a really hard time accepting a "fix" that depends upon behavior
> that the Linux ipv6 stack doesn't even have.

Fair enough. I'm not questioning the defaults or the benefits of
widespread use of flow labels.

I was trying to do this without changing as to how we hash the packets
and balance traffic over multiple paths, but that does yield a solution
that does not work out of the box with Linux endpoints. Hard to sell, I
agree.

As a potential way out, I can rework it so that we exclude the flow
label from the multipath hash. That way we lose some entropy (not worse
than IPv4), but do not depend any more on how flow labels are set
(flexible). This could be made runtime configurable, as it changes
existing behavior.

Thanks,
Jakub
