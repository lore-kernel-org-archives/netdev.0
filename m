From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 2/2] net_sched: optimize tcf_match_indev()
Date: Thu, 19 Dec 2013 22:36:01 -0800
Message-ID: <CAM_iQpWA2qjjEV97SFajg0Y_0WnWAY2qPY9_7vSuFVuYq5tH6Q@mail.gmail.com>
References: <1387503292-20078-1-git-send-email-xiyou.wangcong@gmail.com>
	<1387503292-20078-2-git-send-email-xiyou.wangcong@gmail.com>
	<1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f179.google.com ([209.85.214.179]:62445 "EHLO
	mail-ob0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752429Ab3LTGgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 01:36:02 -0500
Received: by mail-ob0-f179.google.com with SMTP id wm4so2258582obc.24
        for <netdev@vger.kernel.org>; Thu, 19 Dec 2013 22:36:01 -0800 (PST)
In-Reply-To: <1387520573.19078.424.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 19, 2013 at 10:22 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2013-12-19 at 17:34 -0800, Cong Wang wrote:
>> tcf_match_indev() is called in fast path, it is not wise to
>> search for a netdev by ifindex and then compare by its name,
>> just compare the ifindex.
>>
>> This will also save some bytes from the core struct of u32.
>>
>
> This seems very suspect to me. How was it tested ?

Why? I tested it with 1000 u32 filters with mirred actions
to a dummy interface, it is the test case I used from the beginning.

>
> BTW, latest net-next doesn't work anymore.
>
> [   76.591023] BUG: unable to handle kernel paging request at ffffffffffffffff^M
> [   76.598025] IP: [<ffffffffa008d882>] mirred_cleanup_module+0x13a/0x2a [act_mirred]^M


All of my kernel modules are built-in, this is why I can't catch this bug.
So why not share your test case with me?

> I wonder how you tested "net_sched: init struct tcf_hashinfo at register time",
> it is completely buggy.
>

Since I compile everything as built-in, so just boot and shutdown the VM,
and of course, run some test cases like above one.

> static inline int tcf_hashinfo_init(struct tcf_hashinfo *hf, unsigned int mask)
>
> mask is a mask, yet all callers pass 'MASK+1'
>

Hmm, off-by-one error, stupid me.

Again, it is always welcome if you can share your test case.

Thanks.
