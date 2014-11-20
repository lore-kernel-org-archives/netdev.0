From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] bonding: clear header_ops when last slave detached (v2)
Date: Thu, 20 Nov 2014 09:34:26 -0800
Message-ID: <CAHA+R7PKRbBNwfUWRAsVHQreKsGXBc8CHorZRuyCfvwL4O=y+g@mail.gmail.com>
References: <1416374292-10993-1-git-send-email-wen.gang.wang@oracle.com>
	<1416375565.14060.43.camel@edumazet-glaptop2.roam.corp.google.com>
	<546C4022.5010509@oracle.com>
	<CAHA+R7OyA_V149bpE8qUgG9epU-5UG8cf=zOgh5ZXVB3ZFZHUw@mail.gmail.com>
	<1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Wengang <wen.gang.wang@oracle.com>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:59291 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbaKTRe1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 12:34:27 -0500
Received: by mail-qg0-f46.google.com with SMTP id z107so882501qgd.19
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 09:34:26 -0800 (PST)
In-Reply-To: <1416465685.8629.15.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 10:41 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-11-19 at 14:26 -0800, Cong Wang wrote:
>> On Tue, Nov 18, 2014 at 11:00 PM, Wengang <wen.gang.wang@oracle.com> wrote:
>> >
>> > Yes, that's true. So the simplest way is move ipoib_header_ops to vmlinux.
>> >
>>
>> That is not an option. Perhaps you need RCU to protect the dev->header_ops
>> pointer.
>
> This _is_ a reasonable option, especially for stable kernels
>
> ipoib_hard_header() is 100 bytes or less. Adding infrastructure all over
> the kernel to be able to use RCU or module refcounting will cost much
> more.

I didn't look into ipoib_header_ops, thought it might have some dependency
on symbols. So _generally_ speaking, we can't do that, the dependency
chain could be very long. It could be an exception and good luck
to play with module symbols.

>
> Tell me why it is ok for eth_header_ops() being static (while its _much_
> bigger), and not for ipoib_header_ops. This looks pretty arbitrary to
> me.
>

Simple, eth_* is kinda of a builtin library now, too many drivers use them.
