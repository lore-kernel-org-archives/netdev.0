From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: "af_unix: conditionally use freezable blocking calls in read" is wrong
Date: Mon, 5 Dec 2016 20:24:36 -0800
Message-ID: <CAM_iQpXn7ssNpxviX+sLf0k-88GoWubcBeoMW=JkZTh_q8iKdg@mail.gmail.com>
References: <20161204210455.GI1555@ZenIV.linux.org.uk> <20161204.214214.1868750446620130834.davem@davemloft.net>
 <20161205035241.GJ1555@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Colin Cross <ccross@android.com>
To: Al Viro <viro@zeniv.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f195.google.com ([209.85.223.195]:36378 "EHLO
        mail-io0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751576AbcLFE00 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 23:26:26 -0500
Received: by mail-io0-f195.google.com with SMTP id s82so4381476ioi.3
        for <netdev@vger.kernel.org>; Mon, 05 Dec 2016 20:24:57 -0800 (PST)
In-Reply-To: <20161205035241.GJ1555@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 4, 2016 at 7:52 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> On Sun, Dec 04, 2016 at 09:42:14PM -0500, David Miller wrote:
>> >     I've run into that converting AF_UNIX to generic_file_splice_read();
>> > I can kludge around that ("freezable unless ->msg_iter is ITER_PIPE"), but
>> > that only delays trouble.
>> >
>> >     Note that the only other user of freezable_schedule_timeout() is
>> > a very different story - it's a kernel thread, which *does* have a guaranteed
>> > locking environment.  Making such assumptions in unix_stream_recvmsg(),
>> > OTOH, is insane...
>>
>> We have to otherwise Android phones drain their batteries in 10
>> minutes.
>>
>> I'm not going to revert this and be responsible for that.
>>
>> So you have to find a way to make the freezable calls legitimate.
>
> Oh, well...  As I said, I can kludge around that - call from
> generic_file_splice_read() can be distinguished by looking at the
> ->msg_iter->type; it still means unpleasantness for kernel_recvmsg()
> users - in effect, it can only be called with locks held if you know that
> the socket is not an AF_UNIX one.
>
> BTW, how do they deal with plain pipes?

I suppose this question is for Colin. ;)
