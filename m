From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch] mqueue: fix netlink sock refcnt and skb refcnt
Date: Mon, 10 Jul 2017 10:19:38 -0700
Message-ID: <CAM_iQpVCqohQvqdnqe3e__5JpH7Zxr_fAW3ThCPHeaDj1kj+Rg@mail.gmail.com>
References: <1499663303-4514-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Manfred Spraul <manfred@colorfullife.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f171.google.com ([209.85.128.171]:34829 "EHLO
        mail-wr0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932294AbdGJRUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 10 Jul 2017 13:20:05 -0400
In-Reply-To: <1499663303-4514-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jul 9, 2017 at 10:08 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> netlink_sendskb() is problematic, it releases sock refcnt
> silently which could cause troubles we can call it multiple
> times. info->notify_sock is a good example where we
> setup once and use it to send netlink skb's for many times.
> It should not hold or release any refcnt, but needs to rely
> on netlink_attachskb()/netlink_detachskb() to hold/release
> the corresponding refcnt.
>
> Same for the skb attached to this sock, it is allocated once
> and used for multiple times, so we should hold its refcnt
> in netlink_attachskb().
>
> At last, we need to call netlink_detachskb() to release
> both refcnt's after we remove the notification.

Hmm, the info->notify_owner is NULL'ed after sending
the notification, so probably we don't put the sock refcnt
repeatly. Not sure about the skb though...
