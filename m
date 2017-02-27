From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net] ipv6: check for ip6_null_entry in __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 13:12:26 -0800
Message-ID: <CAM_iQpWz2wLL2BsJgDjPvXb_Wgq0Js3QP_cda8wvo+Moh6c8Ww@mail.gmail.com>
References: <1488222425-1256-1-git-send-email-xiyou.wangcong@gmail.com>
 <1488227660.9415.207.camel@edumazet-glaptop3.roam.corp.google.com>
 <0ec7c6bd-0705-ea30-650e-b8d269dc587b@cumulusnetworks.com>
 <CAM_iQpVimUuJZqTkgZOoVtS9O8gL+2rr-SUNgd67Y3L-3bZVZw@mail.gmail.com> <05afcb95-6dd5-753a-ccb3-fe12d5746ffa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35105 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751468AbdB1Bbh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 20:31:37 -0500
Received: by mail-wm0-f44.google.com with SMTP id v186so74284490wmd.0
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 17:31:16 -0800 (PST)
In-Reply-To: <05afcb95-6dd5-753a-ccb3-fe12d5746ffa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2017 at 1:06 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 2/27/17 1:04 PM, Cong Wang wrote:
>>>
>>>                 for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
>>> +                       /* do not allow deletion of the null route */
>>> +                       if (rt == net->ipv6.ip6_null_entry)
>>> +                               continue;
>>>
>>> Fixes: 0ae8133586ad net: ipv6: Allow shorthand delete of all nexthops in
>>> multipath route
>>
>> Note, I moved the check into __ip6_del_rt_siblings() because __ip6_del_rt()
>> has a same check.
>>
>
> that's b/c __ip6_del_rt has a second call path. __ip6_del_rt_siblings is
> new and is not expecting to see the null entry. Catching it before the
> dst_hold would be better.

Yeah, but it also depends on if we want to continue after the null entry,
at least __ip6_del_rt () returns an error for null entry, which looks more
correct than continuing to proceed after it.
