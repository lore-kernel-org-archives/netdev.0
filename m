From: Leon Yang <leon.gh.yang@gmail.com>
Subject: Re: Way to Know When cleanup_net() Calls Are Done
Date: Wed, 5 Jul 2017 18:29:06 -0500
Message-ID: <CAHvAHW-vog2aEAQNgPOOVBNyBqmTiJf-xvwmptszx4mC+jOQCg@mail.gmail.com>
References: <CAHvAHW8aq0Tb0tnNjQAySyDe_pwxHk2-+EHr_yPavuz_aKqAyw@mail.gmail.com>
 <CAM_iQpXH8Ubs9eQdyhr-5qW8gmymyaBdVTFqWqZ4zwvO8Oo2tQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f42.google.com ([209.85.215.42]:34614 "EHLO
        mail-lf0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751964AbdGEX3J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 19:29:09 -0400
Received: by mail-lf0-f42.google.com with SMTP id t72so2000752lff.1
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 16:29:08 -0700 (PDT)
In-Reply-To: <CAM_iQpXH8Ubs9eQdyhr-5qW8gmymyaBdVTFqWqZ4zwvO8Oo2tQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In my case, as I know the number of unshare(2) calls (say 10000), I
think there should be same number of net_drop_ns() calls regardless of
the userns counter. So the 10000th call to net_drop_ns() should be the
last one.

After some investigation I figure out my problem. When I was running
the program, I read the debug/tracing/trace file for a couple times to
check if ftrace was working. This read seems to prevent the ftrace
ring buffer from being written so that some entries are missing from
the ftrace results.

Therefore the problem is completely unrelated to net namespace. Sorry
for the confusion.

On Wed, Jul 5, 2017 at 6:14 PM, Cong Wang <xiyou.wangcong@gmail.com> wrote:
> On Sat, Jul 1, 2017 at 10:50 PM, Leon Yang <leon.gh.yang@gmail.com> wrote:
>> Hi,
>>
>> I am measuring the time cost of parallel creation and destruction of
>> net namespaces.
>>
>> As cleanup_net() is invoked from workqueue, the exit of a net
>> namespace does not mean the cleanup is completed. Therefore I use
>> ftrace to count the number of net_drop_ns() are called. But I found
>> that the number of namespaces created does not match with the number
>> of net_drop_ns() calls even after a long wait.
>>
>> Can you give some hints on why this is happening? and what would be
>> the correct way to know when the last cleanup_net() is done?
>
> Probably no way to know this in user-space, netns is refcount'ed,
> we don't know which is the last one releasing it.
>
> There is a per-userns counter for netns, but I don't see it is ever
> exposed to user-space.
