From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH net-next] net: Implement fast csum_partial for x86_64
Date: Mon, 4 Jan 2016 15:58:22 -0800
Message-ID: <CALx6S34YosSQV6HSWcJh1Z7mJ_15u=7-rcJQFfmqKPtocvkX7g@mail.gmail.com>
References: <1451863347-1832521-1-git-send-email-tom@herbertland.com>
	<1451946988.8255.78.camel@edumazet-glaptop2.roam.corp.google.com>
	<CALx6S370tAh1g5q9trDuFxc84qOozT6XjdSKB94dvGRTUikfvA@mail.gmail.com>
	<1451951576.8255.82.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:33191 "EHLO
	mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbcADX6X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2016 18:58:23 -0500
Received: by mail-io0-f178.google.com with SMTP id q21so170651900iod.0
        for <netdev@vger.kernel.org>; Mon, 04 Jan 2016 15:58:23 -0800 (PST)
In-Reply-To: <1451951576.8255.82.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 4, 2016 at 3:52 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Mon, 2016-01-04 at 15:34 -0800, Tom Herbert wrote:
>> On Mon, Jan 4, 2016 at 2:36 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> > On Sun, 2016-01-03 at 15:22 -0800, Tom Herbert wrote:
>> > \...
>> >> +402: /* Length 2, align is 1, 3, or 5 */
>> >> +     movb    (%rdi), %al
>> >> +     movb    1(%rdi), %ah
>> >
>> > Looks like a movw (%rdi),%ax
>> >
>> Wouldn't that be an unaligned access?
>
> x86 does not care. (This is why we have
> CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
>
> I bet it is faster using a single instruction.
>
Okay, I'll re-implement without worrying about alignment. If it's not
an issue at all (even for eight bytes) then that will be a speedup.

Thanks,
Tom

>
>
