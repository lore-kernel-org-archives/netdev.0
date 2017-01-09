From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [net-next PATCH 1/3] Revert "icmp: avoid allocating large struct
 on stack"
Date: Mon, 9 Jan 2017 09:59:34 -0800
Message-ID: <CAM_iQpV6YQ6nh_Y0f3BDgMheOic3bPiqQ1oNHR+saxxE7nBuoA@mail.gmail.com>
References: <20170109150246.30215.63371.stgit@firesoul> <20170109150404.30215.44512.stgit@firesoul>
 <CAM_iQpUNmaBx6L4CcrXkh6aFj-fEXdoGTBJt+33W3Xg-=7yhWA@mail.gmail.com> <1483984208.5846.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:34300 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1033515AbdAIR75 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 12:59:57 -0500
Received: by mail-qk0-f195.google.com with SMTP id e1so17155497qkh.1
        for <netdev@vger.kernel.org>; Mon, 09 Jan 2017 09:59:57 -0800 (PST)
In-Reply-To: <1483984208.5846.9.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 9, 2017 at 9:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2017-01-09 at 09:42 -0800, Cong Wang wrote:
>> On Mon, Jan 9, 2017 at 7:04 AM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> > This reverts commit 9a99d4a50cb8 ("icmp: avoid allocating large struct
>> > on stack"), because struct icmp_bxm no really a large struct, and
>> > allocating and free of this small 112 bytes hurts performance.
>>
>> The original commit fixes a warning for large stack usage, icmp_send()
>> is deep in the call stack.
>>
>> Your optimization for a slow path makes no sense to me.
>
> Do you have the stack trace of this event ?
>
> Even Linus allowed vmalloc() kernel stacks, while it certainly was an
> heresy 10 years ago.
>
> I doubt it makes a difference trying to save 104 bytes of kernel stack.

I think you should have known this, quote from Eric Dumazet
(hopefully the same one):

    On Fri, 2013-05-31 at 22:22 -0700, Eric Dumazet wrote:

    Strange, I posted a patch like that some days ago.

which is from: https://patchwork.ozlabs.org/patch/248051/

Facepalm...
