From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [Patch net] ipv6: check for ip6_null_entry in
 __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 13:06:49 -0800
Message-ID: <05afcb95-6dd5-753a-ccb3-fe12d5746ffa@cumulusnetworks.com>
References: <1488222425-1256-1-git-send-email-xiyou.wangcong@gmail.com>
 <1488227660.9415.207.camel@edumazet-glaptop3.roam.corp.google.com>
 <0ec7c6bd-0705-ea30-650e-b8d269dc587b@cumulusnetworks.com>
 <CAM_iQpVimUuJZqTkgZOoVtS9O8gL+2rr-SUNgd67Y3L-3bZVZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:36251 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751398AbdB0WKS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 17:10:18 -0500
Received: by mail-pg0-f54.google.com with SMTP id s67so48930846pgb.3
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 14:09:05 -0800 (PST)
In-Reply-To: <CAM_iQpVimUuJZqTkgZOoVtS9O8gL+2rr-SUNgd67Y3L-3bZVZw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/27/17 1:04 PM, Cong Wang wrote:
>>
>>                 for (rt = fn->leaf; rt; rt = rt->dst.rt6_next) {
>> +                       /* do not allow deletion of the null route */
>> +                       if (rt == net->ipv6.ip6_null_entry)
>> +                               continue;
>>
>> Fixes: 0ae8133586ad net: ipv6: Allow shorthand delete of all nexthops in
>> multipath route
> 
> Note, I moved the check into __ip6_del_rt_siblings() because __ip6_del_rt()
> has a same check.
> 

that's b/c __ip6_del_rt has a second call path. __ip6_del_rt_siblings is
new and is not expecting to see the null entry. Catching it before the
dst_hold would be better.
