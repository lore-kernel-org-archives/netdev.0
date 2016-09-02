From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next 2/2] netns: avoid disabling irq for netns id
Date: Fri, 2 Sep 2016 09:39:32 -0700
Message-ID: <CAM_iQpUSoPHDCG5yehmgKgO99Qr_rtR0gZvEeOr3cO-o_LfuXQ@mail.gmail.com>
References: <1472792025-14702-1-git-send-email-xiyou.wangcong@gmail.com>
 <1472792025-14702-3-git-send-email-xiyou.wangcong@gmail.com> <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:35869 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932236AbcIBQjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 12:39:54 -0400
Received: by mail-it0-f67.google.com with SMTP id i184so2418150itf.3
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2016 09:39:53 -0700 (PDT)
In-Reply-To: <7de98923-0cfb-5937-d32b-bdaee7ec10dc@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 2, 2016 at 1:12 AM, Nicolas Dichtel
<nicolas.dichtel@6wind.com> wrote:
> Le 02/09/2016 =C3=A0 06:53, Cong Wang a =C3=A9crit :
>> We never read or change netns id in hardirq context,
>> the only place we read netns id in softirq context
>> is in vxlan_xmit(). So, it should be enough to just
>> disable BH.
>
> Are you sure? Did you audit all part of the code?

I did audit all the callers, and I didn't find any of them in IRQ context.

> peernet2id() is called from netlink core system (do_one_broadcast()). Are=
 you
> sure that no driver call this function from an hard irq context?

I audit all callers of netlink_broadcast(), and I don't see any of
them in hardirq context.

>
> I think that NETLINK_LISTEN_ALL_NSID is largely untested, so it will be h=
ard to
> detect a bug introduced in this feature.

This patch passed my netns stress tests, I have LOCKDEP enabled,
and I don't get any warning or crash etc.
