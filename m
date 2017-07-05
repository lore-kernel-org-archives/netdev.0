From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: Way to Know When cleanup_net() Calls Are Done
Date: Wed, 5 Jul 2017 16:14:54 -0700
Message-ID: <CAM_iQpXH8Ubs9eQdyhr-5qW8gmymyaBdVTFqWqZ4zwvO8Oo2tQ@mail.gmail.com>
References: <CAHvAHW8aq0Tb0tnNjQAySyDe_pwxHk2-+EHr_yPavuz_aKqAyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Leon Yang <leon.gh.yang@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:34441 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752467AbdGEXPQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 19:15:16 -0400
Received: by mail-wr0-f180.google.com with SMTP id 77so4950474wrb.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 16:15:15 -0700 (PDT)
In-Reply-To: <CAHvAHW8aq0Tb0tnNjQAySyDe_pwxHk2-+EHr_yPavuz_aKqAyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 1, 2017 at 10:50 PM, Leon Yang <leon.gh.yang@gmail.com> wrote:
> Hi,
>
> I am measuring the time cost of parallel creation and destruction of
> net namespaces.
>
> As cleanup_net() is invoked from workqueue, the exit of a net
> namespace does not mean the cleanup is completed. Therefore I use
> ftrace to count the number of net_drop_ns() are called. But I found
> that the number of namespaces created does not match with the number
> of net_drop_ns() calls even after a long wait.
>
> Can you give some hints on why this is happening? and what would be
> the correct way to know when the last cleanup_net() is done?

Probably no way to know this in user-space, netns is refcount'ed,
we don't know which is the last one releasing it.

There is a per-userns counter for netns, but I don't see it is ever
exposed to user-space.
