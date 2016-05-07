From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v3 net-next 00/11] ipv6: Enable GUEoIPv6 and more fixes
 for v6 tunneling
Date: Fri, 6 May 2016 19:03:24 -0700
Message-ID: <CAKgT0UdM1aQF8cLWVLXMmXyJnMHkZUum8YyKsyCSVFvBALmyCA@mail.gmail.com>
References: <1462572726-566137-1-git-send-email-tom@herbertland.com>
	<CAKgT0UdvZbDsDewsGRvMO93OZNSSXKfWaT7RvWkb6DQaG9jvyA@mail.gmail.com>
	<CALx6S36uA83qEoYw2daxHrpege0zyNO=5u0iJ9tZu=RaBAK8cA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>, Kernel Team <kernel-team@fb.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:35457 "EHLO
	mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758818AbcEGCDZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 May 2016 22:03:25 -0400
Received: by mail-io0-f169.google.com with SMTP id d62so130096751iof.2
        for <netdev@vger.kernel.org>; Fri, 06 May 2016 19:03:24 -0700 (PDT)
In-Reply-To: <CALx6S36uA83qEoYw2daxHrpege0zyNO=5u0iJ9tZu=RaBAK8cA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, May 6, 2016 at 6:57 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Fri, May 6, 2016 at 6:09 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On Fri, May 6, 2016 at 3:11 PM, Tom Herbert <tom@herbertland.com> wrote:
>>> This patch set:
>>>   - Fixes GRE6 to process translate flags correctly from configuration
>>>   - Adds support for GSO and GRO for ip6ip6 and ip4ip6
>>>   - Add support for FOU and GUE in IPv6
>>>   - Support GRE, ip6ip6 and ip4ip6 over FOU/GUE
>>>   - Fixes ip6_input to deal with UDP encapsulations
>>>   - Some other minor fixes
>>>
>>> v2:
>>>   - Removed a check of GSO types in MPLS
>>>   - Define GSO type SKB_GSO_IPXIP6 and SKB_GSO_IPXIP4 (based on input
>>>     from Alexander)
>>>   - Don't define GSO types specifally for IP6IP6 and IP4IP6, above
>>>     fix makes that uncessary
>>>   - Don't bother clearing encapsulation flag in UDP tunnel segment
>>>     (another item suggested by Alexander).
>>>
>>> v3:
>>>   - Address some minor comments from Alexander
>>>
>>> Tested:
>>>    Tested a variety of case, but not the full matrix (which is quite
>>>    large now). Most of the obivous cases (e.g. GRE) work fine. Still
>>>    some issues probably with GSO/GRO being effective in all cases.
>>>
>>>     - IPv4/GRE/GUE/IPv6 with RCO
>>>       1 TCP_STREAM
>>>         6616 Mbps
>>>       200 TCP_RR
>>>         1244043 tps
>>>         141/243/446 90/95/99% latencies
>>>         86.61% CPU utilization
>>>     - IPv6/GRE/GUE/IPv6 with RCO
>>>       1 TCP_STREAM
>>>         6940 Mbps
>>>       200 TCP_RR
>>>         1270903 tps
>>>         138/236/440 90/95/99% latencies
>>>         87.51% CPU utilization
>>>
>>>      - IP6IP6
>>>       1 TCP_STREAM
>>>         2576 Mbps
>>>       200 TCP_RR
>>>         498981 tps
>>>         388/498/631 90/95/99% latencies
>>>         19.75% CPU utilization (1 CPU saturated)
>>>
>>>      - IP6IP6/GUE/IPv6 with RCO
>>>       1 TCP_STREAM
>>>         1854 Mbps
>>>       200 TCP_RR
>>>         1233818 tps
>>>         143/244/451 90/95/99% latencies
>>>         87.57 CPU utilization
>>>
>>>      - IP4IP6
>>>       1 TCP_STREAM
>>>       200 TCP_RR
>>>         763774 tps
>>>         250/318/466 90/95/99% latencies
>>>         35.25% CPU utilization (1 CPU saturated)
>>>
>>>      - GRE with keyid
>>>       200 TCP_RR
>>>         744173 tps
>>>         258/332/461 90/95/99% latencies
>>>         34.59% CPU utilization (1 CPU saturated)
>>
>> So I tried testing your patch set and it looks like I cannot get GRE
>> working for any netperf test.  If I pop the patches off it is even
>> worse since it looks like patch 3 fixes some tunnel flags issues, but
>> still doesn't resolve all the issues introduced with b05229f44228
>> ("gre6: Cleanup GREv6 transmit path, call common GRE functions").
>> Reverting the entire patch seems to resolve the issues, but I will try
>> to pick it apart tonight to see if I can find the other issues that
>> weren't addressed in this patch series.
>>
>
> Can you give details about configuration, test you're running, and HW?

The issue looks like it may be specific to ip6gretap.  I'm running the
test over an i40e adapter, but it shouldn't make much difference.  I'm
thinking it may have something to do with the MTU configuration as
that is one of the things I am noticing has changed between the
working and the broken version of the code.

- Alex
