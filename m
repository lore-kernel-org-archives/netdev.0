From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net v3] ipv6: check for ip6_null_entry in __ip6_del_rt_siblings()
Date: Mon, 27 Feb 2017 16:40:24 -0800
Message-ID: <CAM_iQpXz6QnhLYFFD=-iE_yfgUZ13_o+u_VMffWgr0hxE_fZXA@mail.gmail.com>
References: <1488240463-12000-1-git-send-email-xiyou.wangcong@gmail.com> <6d332a15-d86c-0b02-61e5-38d208f2caf7@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34774 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751419AbdB1Akq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 27 Feb 2017 19:40:46 -0500
Received: by mail-wm0-f53.google.com with SMTP id 196so21027248wmm.1
        for <netdev@vger.kernel.org>; Mon, 27 Feb 2017 16:40:45 -0800 (PST)
In-Reply-To: <6d332a15-d86c-0b02-61e5-38d208f2caf7@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 27, 2017 at 4:14 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> On 2/27/17 4:07 PM, Cong Wang wrote:
>> Andrey reported a NULL pointer deref bug in ipv6_route_ioctl()
>> -> ip6_route_del() -> __ip6_del_rt_siblings() code path. This is
>> because ip6_null_entry is returned in this path since ip6_null_entry
>> is kinda default for a ipv6 route table root node. Quote from
>
>
> Missed this earlier. The issue here is an attempt to delete the NULL
> route, not that the null_entry is being returned as happens during a
> route lookup. This will also hit the bug:
>     ip -6 ro del ::/0

By "returned" I mean it is in the fn->leaf list.
