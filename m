From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: cross namespace interface notification for tun devices
Date: Tue, 19 Sep 2017 13:40:49 -0700
Message-ID: <CAM_iQpVvDNRbtj_47_3XXa_ezyrT=a_VzDtK5SCR9a4_2Gqw9w@mail.gmail.com>
References: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Netdev <netdev@vger.kernel.org>, Mathias <mathias@hall-andersen.dk>
To: "Jason A. Donenfeld" <Jason@zx2c4.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:43719 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751488AbdISUlK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 16:41:10 -0400
Received: by mail-pg0-f54.google.com with SMTP id u18so473589pgo.0
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 13:41:09 -0700 (PDT)
In-Reply-To: <CAHmME9pD_kees+xrjTeWXgi26UdhbMVgvoddbCyueTZkbguvAg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 18, 2017 at 11:47 AM, Jason A. Donenfeld <Jason@zx2c4.com> wrote:
> Hey guys,
>
> It's possible to create a tun device in a process in namespace A and
> then move that interface to namespace B. The controlling process in A
> needs to receive notifications on when the interface is brought up or
> down. It can receive these notifications via netlink while the
> interface lives in A but not when it moves to B.

By "notification" I assume you mean netlink notification.

>
> Any tricks or APIs to get around this?

The question is why does the process in A still care about
the device sitting in B?

Also, the process should be able to receive a last notification
on IFF_UP|IFF_RUNNING before device is finally moved to B.
After this point, it should not have any relation to netns A
any more, like the device were completely gone.
