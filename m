From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Sun, 4 Sep 2016 22:23:47 +0200
Message-ID: <13f8e19f-1a65-c6e4-0b9c-2c0e37cadff6@6wind.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com>
 <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com>
 <CAM_iQpUSoPHDCG5yehmgKgO99Qr_rtR0gZvEeOr3cO-o_LfuXQ@mail.gmail.com>
 <CAM_iQpUZOVbYvcfK9BriSsSdsC5BMcgbWxZZJzNARV4pcTmZkA@mail.gmail.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f43.google.com ([74.125.82.43]:38644 "EHLO
        mail-wm0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754418AbcIDUXu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 4 Sep 2016 16:23:50 -0400
Received: by mail-wm0-f43.google.com with SMTP id 1so107394538wmz.1
        for <netdev@vger.kernel.org>; Sun, 04 Sep 2016 13:23:49 -0700 (PDT)
In-Reply-To: <CAM_iQpUZOVbYvcfK9BriSsSdsC5BMcgbWxZZJzNARV4pcTmZkA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/09/2016 à 19:24, Cong Wang a écrit :
> On Fri, Sep 2, 2016 at 9:39 AM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
>> On Fri, Sep 2, 2016 at 1:12 AM, Nicolas Dichtel
>> <nicolas.dichtel@6wind.com> wrote:
>>> Le 02/09/2016 à 06:53, Cong Wang a écrit :
>>>> We never read or change netns id in hardirq context,
>>>> the only place we read netns id in softirq context
>>>> is in vxlan_xmit(). So, it should be enough to just
>>>> disable BH.
>>>
>>> Are you sure? Did you audit all part of the code?
>>
>> I did audit all the callers, and I didn't find any of them in IRQ context.
>>
>>> peernet2id() is called from netlink core system (do_one_broadcast()). Are you
>>> sure that no driver call this function from an hard irq context?
>>
>> I audit all callers of netlink_broadcast(), and I don't see any of
>> them in hardirq context.
> 
> Note, you can rule out most of them by checking GFP_KERNEL,
> which indicates a process context. ;) For GFP_ATOMIC cases,
> I don't see any of them in hardirq context either, but I am definitely
> not familiar with drivers like infiniband.
> 
Yes, I was thinking to that one. But I'm also not familiar with it ;-)
