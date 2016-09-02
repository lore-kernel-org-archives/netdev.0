From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Fri, 2 Sep 2016 10:24:15 -0700
Message-ID: <CAM_iQpUZOVbYvcfK9BriSsSdsC5BMcgbWxZZJzNARV4pcTmZkA@mail.gmail.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
 <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com> <CAM_iQpUSoPHDCG5yehmgKgO99Qr_rtR0gZvEeOr3cO-o_LfuXQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:34935 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932495AbcIBRYg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 13:24:36 -0400
Received: by mail-it0-f68.google.com with SMTP id c198so2551578ith.2
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 10:24:35 -0700 (PDT)
In-Reply-To: <CAM_iQpUSoPHDCG5yehmgKgO99Qr_rtR0gZvEeOr3cO-o_LfuXQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 9:39 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Fri, Sep 2, 2016 at 1:12 AM, Nicolas Dichtel
> <nicolas.dichtel@6wind.com> wrote:
>> Le 02/09/2016 =C3=A0 06:53, Cong Wang a =C3=A9crit :
>>> We never read or change netns id in hardirq context,
>>> the only place we read netns id in softirq context
>>> is in vxlan_xmit(). So, it should be enough to just
>>> disable BH.
>>
>> Are you sure? Did you audit all part of the code?
>
> I did audit all the callers, and I didn't find any of them in IRQ context=
.
>
>> peernet2id() is called from netlink core system (do_one_broadcast()). Ar=
e you
>> sure that no driver call this function from an hard irq context?
>
> I audit all callers of netlink_broadcast(), and I don't see any of
> them in hardirq context.

Note, you can rule out most of them by checking GFP_KERNEL,
which indicates a process context. ;) For GFP_ATOMIC cases,
I don't see any of them in hardirq context either, but I am definitely
not familiar with drivers like infiniband.
